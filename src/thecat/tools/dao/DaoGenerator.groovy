package thecat.tools.dao;

import java.lang.reflect.Modifier;

import org.codehaus.groovy.gfreemarker.FreeMarkerTemplateEngine
import org.apache.commons.lang.ClassUtils
import org.apache.commons.lang.StringUtils
import org.apache.commons.lang.reflect.MethodUtils;
import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils

def keyValueArgs = args.collect { def token = it.split('='); [key: token[0], value: token.length > 1 ? token[1] : null] }

keyValueArgs.findAll { it.key in [
	'-generate-dao-base-classes', '-osiv-dao', '-spring-dao', 
	'-generate-spring-cfg', '-generate-ehcache-cfg', '-use-ehcache',
	'-generate-osiv-filter', '-generate-orm-cfg', '-include-super-fields', 
	'-verbose'] }.each { it.value = true }

// check input parameters
if (	(keyValueArgs.size() < 1) ||
		(keyValueArgs.findAll { it.key in ['-fq-class-name'] }.size() != 1) || 
		(keyValueArgs.findAll { it.value == null }.size() > 0)) {
	showUsage()
	return
} 

def fqClassName = keyValueArgs.find { it.key == '-fq-class-name'}.value
def keyField = keyValueArgs.find { it.key == '-key-field-name'}?.value
def outputPackage = keyValueArgs.find { it.key == '-output-package'}?.value
def generateDaoBaseClass = keyValueArgs.find { it.key == '-generate-dao-base-classes'}?.value
def osivDao = keyValueArgs.find { it.key == '-osiv-dao'}?.value
def springDao = keyValueArgs.find { it.key == '-spring-dao'}?.value
def useEhcache = keyValueArgs.find { it.key == '-use-ehcache'}?.value ?: false
def generateOsivFilter = keyValueArgs.find { it.key == '-generate-osiv-filter'}?.value
def generateOrmCfg = keyValueArgs.find { it.key == '-generate-orm-cfg'}?.value
def generateSpringCfg = keyValueArgs.find { it.key == '-generate-spring-cfg'}?.value
def generateEhcacheCfg = keyValueArgs.find { it.key == '-generate-ehcache-cfg'}?.value
def includeSuperFields = keyValueArgs.find { it.key == '-include-super-fields'}?.value ?: false
def useOrm =  keyValueArgs.find { it.key == '-use-orm'}?.value ?: 'hibernate'
def useDb =  keyValueArgs.find { it.key == '-use-db'}?.value ?: 'mysql'
def verboseOutput   = keyValueArgs.find { it.key == '-verbose'}?.value
def key = null


try {
	if (keyField) {
		key = findIdUsingName(fqClassName, keyField)
	} else {
		key = findIdUsingAnnotation(fqClassName)
	}
} catch (Exception ex) {
	println "HUSTON, WE HAVE A PROBLEM!!! - $ex"
	return
}

if (!key) {
	println "HUSTON, WE HAVE A PROBLEM!!! - Identity attribute/get method not found for the specifed class ${fqClassName}"
	return
}

// if the output package is not specified try to generate one
if (!outputPackage) {
	outputPackage = calculateDaoPackage(fqClassName)
}

//println "osivDao: ${osivDao}"
//println "generateOsivFilter: ${generateOsivFilter}"

def classForDao = null
def superClassForDao = null
try {
	classForDao = Class.forName(fqClassName)
	superClassForDao = classForDao.getSuperclass()
	//println "superClassForDao: ${superClassForDao.canonicalName}"
} catch (ClassNotFoundException ex) {
	println "Cannot find the required class in the current classpath!!!"
	println "ClassPath: ${System.getProperties().getProperty('java.class.path', null)}"
	return
}

def binding = ['packageName': outputPackage, 'className': classForDao.simpleName , 'fqClassName': fqClassName, 
			   'entityName': StringUtils.uncapitalize(classForDao.simpleName),
               'fieldList': [], 'importList': [], 
			   'keyField': key.fieldName, 'keyFieldType': key.fieldType, 
			   'useEhcache': useEhcache,
               'isAbstract': Modifier.isAbstract(classForDao.modifiers),
			   'implementation': '', 'useDb': useDb]

// collect the fields name and type of classForDao
getFields(classForDao, keyValueArgs, fqClassName).each { binding.fieldList.add(it) }
def declaredGetMethods = classForDao.getDeclaredMethods().findAll {
	it.name.startsWith("get")
}

println binding.fieldList

// collect if required super fields when != java.lang.Object
if (includeSuperFields && (superClassForDao.canonicalName != 'java.lang.Object')) {
	def currentFieldsName = binding.fieldList.collect { it.fieldName }.flatten()
	def fields = getFields(superClassForDao, keyValueArgs, fqClassName)
	fields.findAll { ! (it.fieldName in currentFieldsName) }.each {
		binding.fieldList.add(it)
	}
	
	def getMethods = declaredGetMethods.collect { it.name }
	superClassForDao.getDeclaredMethods().findAll {
		it.name.startsWith("get")
	}.each {
		if (! (it.name in getMethods)) {
			declaredGetMethods.add(it)
		} 
	}
}

//println "fields: ${binding.fieldList}"
//println "getDeclaredMethods: ${declaredGetMethods}"

// Collect class to import
def typesForMethods = declaredGetMethods.collect() { getType(it).type }
def genericsForMethods =  declaredGetMethods.collect() { getType(it).generic }.findAll() { it != null }.collect() { it.type }.flatten()
def types = typesForMethods + genericsForMethods
if (declaredGetMethods.find { def itType = getType(it).type; itType.startsWith('java.util.Set') || itType.startsWith('java.util.List') }) {
	types += [ 'java.util.ArrayList' ]
}
types.add(classForDao.name)

//println "typesForMethods: ${typesForMethods}"
//println "genericsForMethods: ${genericsForMethods}"
//println "types: ${types}"

// sort + removes the duplicate type, java.lang.*, java.util.List and primitive types 
types.sort().unique().findAll { !it.startsWith('java.lang.') && it != 'java.util.List' && (it.contains('.') || it != it.toLowerCase())}.each { binding.importList.add(it) }

//println "field list: ${binding.fieldList}"
//println "importList: ${binding.importList}"

// setup interface implementation type
if (osivDao) {
	binding.implementation = 'Osiv'
} else if (springDao) {
	binding.implementation = 'Spring'
}

def files4config = [
	'hibernate' : [
		'baseDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [
				'hibernate/Dao.java.tpl', 'GenericDao.java.tpl', 'GenericPK.java.tpl',
				'GenericDaoExt.java.tpl', "hibernate/GenericDao${binding['implementation']}Impl.java.tpl"]],
		'entityDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: ['${className}Dao.java.tpl', "hibernate/\${className}Dao${binding['implementation']}Impl.java.tpl"]],
		'config':  [
			inputDir: 'tpl/hibernate', outputDir: 'cfg',
			files: [
				(generateOrmCfg 		? 'hibernate.cfg.xml.tpl' : ''),
				(generateSpringCfg 		? 'applicationContext.xml.tpl' : ''),
				(generateEhcacheCfg 	? 'ehcache.xml.tpl' : '')]], 
		'java-util': [ 
			inputDir: 'tpl/hibernate', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [(generateOsivFilter 	? 'HibernateOsivFilter.java.tpl' : '') ]], ],
	'mybatis' : [
		'baseDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [
				'mybatis/Dao.java.tpl', 'GenericDao.java.tpl', 'GenericPK.java.tpl',
				'GenericDaoExt.java.tpl', "mybatis/GenericDao${binding['implementation']}Impl.java.tpl"]],
		'mapper': [
			inputDir: 'tpl/mybatis', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}/mapper",
			files: [
				'GenericMapper.java.tpl', '${className}Mapper.java.tpl',
				"\${className}Mapper-${binding.useDb}.xml.tpl"]],
		'entityDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: ['${className}Dao.java.tpl', "mybatis/\${className}Dao${binding['implementation']}Impl.java.tpl"]],
		'config':  [
			inputDir: 'tpl/mybatis', outputDir: 'cfg',
			files: [
				(generateOrmCfg 		? 'mybatis.xml.tpl' : ''),
				(generateSpringCfg 		? 'applicationContext.xml.tpl' : ''),
				(generateEhcacheCfg 	? 'ehcache.xml.tpl' : '')]], 
		'java-util': [ 
			inputDir: 'tpl/mybatis', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [(generateOsivFilter 	? 'MyBatisOsivFilter.java.tpl' : '') ]] ]]


showRunInfo(
	outputPackage, classForDao, superClassForDao, 
	includeSuperFields, key.fieldName, 
	binding.isAbstract, binding.fieldList, 
	osivDao, useOrm, verboseOutput)

// setup config files
def files = null
files4config.each { config ->
	config.key.split(',').each {
		if (it == useOrm) {
			files = config.value
		}
	}
}

if (!files) {
	println "Cannot find the specified ${useOrm} orm technology!!!"
	System.exit 0
}

files.each { section ->
	def inputDir = section.value.inputDir
	def baseOutputDir = "output-${useOrm}"
	def outputDir = section.value.outputDir

	// TODO check for file count excluding the empty entries before makedir	
	FileUtils.forceMkdir(new File("${baseOutputDir}/${outputDir}"))
	
	section.value.files.each { file ->
		if (!file.isEmpty()) {
			def fileEx = freemark(file, binding)
			def fileNameEx = FilenameUtils.getName(fileEx)
			def inputFile = "${inputDir}/${file}"
			def outputFile = freemark(fileNameEx, binding)
		
			if (inputFile.endsWith('.tpl')) {
				def outputFileNoTpl = FilenameUtils.removeExtension(outputFile)
				if (verboseOutput) println "\t\t${inputFile} --> ${baseOutputDir}/${outputDir}/${outputFileNoTpl}"
				
				freemark("${inputFile}", "${baseOutputDir}/${outputDir}/${outputFileNoTpl}", binding)
			} else {
				if (verboseOutput) println "\t\t${inputFile} --> ${baseOutputDir}/${outputDir}/${outputFile}"
				
				FileUtils.copyURLToFile getClass().getResource(inputFile),
					new File("${baseOutputDir}/${outputDir}/${outputFile}")
			}
		}
	}
}

println "That's all Folks!!!"

def calculateDaoPackage(fqClassName) {
	def splittedPackage = []
	def daoPackage = null
	def splittedFqClassName = fqClassName.split('[.]')
	 
	splittedFqClassName.eachWithIndex { it, i -> if (i+1 != splittedFqClassName.size()) splittedPackage.add it }
	
	if (splittedPackage.contains('model')) {
		daoPackage = splittedPackage[0..(splittedPackage.findIndexOf { it == 'model' } - 1)].join('.') + '.dao'
	} else {
		if (splittedPackage.size() > 2) {
			daoPackage = splittedPackage[0..(splittedPackage.size() - 3)].join('.') + '.dao'
		} else {
			daoPackage = splittedPackage.join('.')
		}
	}
	
	daoPackage
}

def findIdUsingName(fqClassName, name) {

	findIdUsingPredicate(fqClassName, {element -> element instanceof java.lang.reflect.Field ?
			element.name == name :
			element.name.startsWith('get') && StringUtils.uncapitalize(element.name.substring(3)) == name})
	
}

def findIdUsingAnnotation(fqClassName) {	
	
	findIdUsingPredicate(fqClassName, {element -> element.annotations*.annotationType().name.find { annotation -> annotation == 'javax.persistence.Id' }})

}

// TODO watch-out for generics types
def findIdUsingPredicate(fqClassName, predicate) {
	def clazz = Class.forName(fqClassName)
	def idField = null
	
	if (clazz.annotations.find { it.annotationType().name == 'javax.persistence.Entity' }) {
		def elementsToCheck = []
		clazz.fields.each { elementsToCheck.add it}
		clazz.methods.each { elementsToCheck.add it }
		
		def elementFound = elementsToCheck.find { element ->
			predicate(element)
		}
		
		if (elementFound) {
			if (elementFound instanceof java.lang.reflect.Field) {
				idField = [fieldName: elementFound.name, fieldType: elementFound.type.name]
			} else {
				if (elementFound.name.startsWith('get')) {
					idField = [fieldName: StringUtils.uncapitalize(elementFound.name.substring(3)), fieldType: elementFound.returnType.name]
				} else {
					println 'You should annotate the get method for entity identifier (@Id)'
				}
			}
		}
	} else {
		println 'HUSTON, WE HAVE A PROBLEM!!! - The specified entity have no @Entity annotation.'
		System.exit(0)
	}
	
	if (idField) {
		if (idField.fieldType.startsWith('java.lang.')) {
			idField.fieldType = idField.fieldType.substring(10)
		}
	}
	
	idField
}

def freemark(inputString, binding) {
	def engine = new FreeMarkerTemplateEngine('')
	
	return (String) engine.createTemplate(inputString).make(binding)
}

def freemark(templateName, outputClassName, binding) {
	def engine = new FreeMarkerTemplateEngine('')
	
	def templateUrl = getClass().getResource(templateName);
	def templateText = templateUrl.getContent().getText()
	String classText = engine.createTemplate(templateText).make(binding)
	new File(outputClassName).setText(classText)

	//println classText
}

def getType(type) {
	if (type.getReturnType().toString() == type.getGenericReturnType().toString()) {
		return [type: type.returnType.name]
	} else {
		def returnType = [type: type.getReturnType().name, generic: []]
	
		def genericReturnType = type.getGenericReturnType().toString()
		genericReturnType = genericReturnType.substring(genericReturnType.indexOf("<") + 1, genericReturnType.lastIndexOf(">"))
		genericReturnType.split(',').each {
			returnType.generic.add([type: it])
		}
		
		return returnType
	}
}

def getFields(clazz, keyValueArgs, fqClassName) {
	def fields = []
		
	def declaredGetMethods = clazz.getDeclaredMethods().findAll {
		it.name.startsWith("get") && ! it.annotations.find { annotation -> annotation.annotationType().name == 'javax.persistence.Transient' }
	}.each {
		def returnType = getType(it)
		def typeAsString = ClassUtils.getShortCanonicalName(returnType.type)
		def fqTypeAsString = ClassUtils.getCanonicalName(returnType.type)
		def subType = null
		def isSubType = false
		if (returnType.generic != null) {
			typeAsString += "<" +
				returnType.generic.collect {
					ClassUtils.getShortCanonicalName(it.type)
				}.join(', ') + ">"
			fqTypeAsString += "<" +
			returnType.generic.collect {
				ClassUtils.getCanonicalName(it.type)
			}.join(', ') + ">"
		
			subType = ClassUtils.getCanonicalName(returnType.generic[0].type)
			isSubType = ClassUtils.getCanonicalName(subType).startsWith('java.lang.') ? false : true
		} else {
			if (!fqTypeAsString.startsWith('java.lang')) {
				subType = fqTypeAsString
				isSubType = true
			}
		}	
			
		println "field: ${clazz} - ${it.name.substring(3)}, isSubType: ${isSubType}, subType: ${subType}"

		if (subType != fqClassName) {			
		
			// check id name/type for generic attribute (ex. List, Set)
			def field = null
			if (isSubType) {
				
				// check for @Id annotation
				field = findAnnotatedField(Class.forName(subType), 'javax.persistence.Id')
				
				// check for id name/type entity params
				if (field == null) {
					field = findIdFromParams(ClassUtils.getShortCanonicalName(subType), keyValueArgs)
				}
				
				// this is the default id name/type configuration
				if (field == null) {
					field = [name: 'id', type: 'Long']
				}
			}
			
			if (field) {
				if (isSubType) {
					fields.add([fieldName: "${StringUtils.uncapitalize(it.name.substring(3))}", fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}", fieldId: [fieldName: field?.name, fieldType: field?.type], fieldList: getFields(Class.forName(subType), field?.name, fqClassName)])
				} else {
					fields.add([fieldName: "${StringUtils.uncapitalize(it.name.substring(3))}", fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}", fieldId: [fieldName: field?.name, fieldType: field?.type]])
				}
			} else {
				if (isSubType) {
					fields.add([fieldName: "${StringUtils.uncapitalize(it.name.substring(3))}", fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}", fieldId: [fieldName: field?.name, fieldType: field?.type], fieldList: getFields(Class.forName(subType), field?.name, fqClassName)])
				} else {
					fields.add([fieldName: "${StringUtils.uncapitalize(it.name.substring(3))}", fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}"])
				}
			}
		}
	}
	
	fields
}

def findAnnotatedField(Class type, annotationTypeName) {
	def field = null
	
	type.getDeclaredMethods().findAll { it.name.startsWith("get") }.each { method ->
		method.annotations.each { println "Annotation: ${it.annotationType().canonicalName}" }
		if (method.annotations.find { it.annotationType().canonicalName == annotationTypeName } != null) {
			field = [	name: StringUtils.uncapitalize(method.name.substring(3)),
						type: ClassUtils.getShortCanonicalName(getType(method).type) ]
		}
	}
	
	return field
}

def findIdFromParams(type, keyValueArgs) {
	def field = null
	
	def fieldName = keyValueArgs.find { it.key == "-${type}-key-field-name" }?.value
	def fieldType = keyValueArgs.find { it.key == "-${type}-key-field-type" }?.value
	
	if (fieldName != null && fieldType != null) {
		field = [name: fieldName, type: fieldType]
	}
	
	field
}

// TODO print the dao classes if required
def showRunInfo(outputPackage, classForDao, superClassForDao, includeSuperFields, keyField, isAbstract, fields, osivDao, useOrm, verboseOutput) {
	println "Entity class: ${classForDao.name}${isAbstract ? ' (abstract)' : ''}${includeSuperFields && superClassForDao.name != 'java.lang.Object' ? ' (+' + superClassForDao.name + ')' : ''}"
	println "Output package: ${outputPackage}"
	println "Orm technology: ${useOrm}"
	println "Entity key field: ${keyField}"
	println ""
	println "Attributes found: (* - key field)"
	fields.each { field ->
		def props = []
		if (field.fieldName == keyField) props.add('(*)')
		println "\t${field.fieldType} ${field.fieldName} ${props.join(' ')}" 
	}
	println ""
	print "Generating code ${osivDao ? 'using osiv filter, see http://community.jboss.org/wiki/OpenSessioninView' : ''}"
	if (verboseOutput)
		println ''
	else 
		print '...'
}


def showUsage() {
	println "Please specify the following parameters:"
	println "\t-fq-class-name=<full qualified class name of the entity from which generate the Dao code>"
	println "\t[-key-field-name=<key field of the entity>]"
	println "\t[-output-package=<package of the generated dao code>]"
	println "\t[-include-super-fields]"
	println "\t[-osiv-dao]"
	println "\t[-spring-dao]"
	println "\t[-use-ehcache]"
	println "\t[-use-db=<db name> select the specific db - default: mysql"
	println "\t\tAvailable dbs: mysql, postgres"
	println "\t[-generate-orm-cfg]"
	println "\t[-generate-spring-cfg]"
	println "\t[-generate-ehcache-cfg]"
	println "\t[-generate-dao-base-classes]"
	println "\t[-generate-osiv-filter] see http://community.jboss.org/wiki/OpenSessioninView"
	println "\t[-use-orm=<orm technoly to use>] technology configuration - default: hibernate"
	println "\t[-verbose] verbose output"
	println "\tAvailable orms: hibernate, mybatis"
}
