// generazione dello script sql x ormlite
package thecat.tools.dao;

import java.lang.reflect.Modifier;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.ClassUtils;
import org.apache.commons.lang.StringUtils;
import org.codehaus.groovy.gfreemarker.FreeMarkerTemplateEngine;


def keyValueArgs = args.collect { def token = it.split('='); [key: token[0], value: token.length > 1 ? token[1] : null] }

keyValueArgs.findAll { it.key in [
	'-generate-dao-base-classes', '-osiv-dao', '-spring-dao', 
	'-generate-spring-cfg', '-generate-ehcache-cfg', '-use-ehcache',
	'-generate-osiv-filter', '-generate-orm-cfg', '-include-super-fields',
	'-generate-rest', '-generate-rest-swagger-ui',
	'-verbose'] }.each { it.value = true }

// check input parameters
if (	(keyValueArgs.size() < 1) ||
		(keyValueArgs.findAll { it.key in ['-fq-class-name'] }.size() != 1) ||
		(keyValueArgs.findAll { it.value == null }.size() > 0)) {
	showUsage()
	return
}

def fqClassName = keyValueArgs.find { it.key == '-fq-class-name'}?.value
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
def generateRest = keyValueArgs.find { it.key == '-generate-rest' }?.value ?: false
def restFormat = keyValueArgs.find { it.key == '-use-rest-format' }?.value ?: 'json+xml'
def generateSwaggerUi = keyValueArgs.find { it.key == '-generate-rest-swagger-ui' }?.value ?: false
def appServerHost = keyValueArgs.find { it.key == '-host' }?.value ?: 'localhost'
def appServerPort = keyValueArgs.find { it.key == '-port' }?.value ?: '8080'

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

if (!(restFormat in ['json+xml', 'json', 'xml'])) {
	println "HUSTON, WE HAVE A PROBLEM!!! Invalid rest format specified"
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

warName = keyValueArgs.find { it.key == '-war-name' }?.value ?: "${classForDao.simpleName}RestWS"

def binding = ['packageName': outputPackage, 'className': classForDao.simpleName , 'fqClassName': fqClassName, 
			   'entityName': StringUtils.uncapitalize(classForDao.simpleName),
               'fieldList': [], 'importList': [], 
			   'keyField': key.fieldName, 'keyFieldType': key.fieldType, 
			   'useEhcache': useEhcache,
               'isAbstract': Modifier.isAbstract(classForDao.modifiers),
			   'implementation': '', 'useDb': useDb,
			   'generateRest': generateRest, 'restFormat': restFormat, 'generateSwaggerUi': generateSwaggerUi,
			   'host': appServerHost, 'port': appServerPort, 'warName': warName
			   ]

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

// TODO use config slurper to externalize the config array
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
			files: [(generateOsivFilter 	? 'HibernateOsivFilter.java.tpl' : '') ]], 
		'rest': [
			inputDir: 'tpl/rest', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [
				(generateRest ? '${className}Application.java.tpl' : ''), 
				(generateRest ? '${className}Service.java.tpl' : '')]],
		'swagger-ui': [
			inputDir: 'tpl/rest/swaggerui', outputDir: 'web',
			files: [
				(generateRest && generateSwaggerUi ? 'swaggerui.zip.unzipme' : ''),
				(generateRest && generateSwaggerUi? 'index.html.tpl' : '')]],
		'web':  [
			inputDir: 'tpl/web', outputDir: 'cfg',
			files: [
				(generateRest ? 'web.xml.tpl' : '')]] ],
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
			files: [(generateOsivFilter 	? 'MyBatisOsivFilter.java.tpl' : '') ]],
		'rest': [
			inputDir: 'tpl/rest', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [
				(generateRest ? '${className}Application.java.tpl' : ''), 
				(generateRest ? '${className}Service.java.tpl' : '')]],
		'swagger-ui': [
			inputDir: 'tpl/rest/swaggerui', outputDir: 'web',
			files: [
				(generateRest && generateSwaggerUi ? 'swaggerui.zip.unzipme' : ''),
				(generateRest && generateSwaggerUi? 'index.html.tpl' : '')]],
		'web':  [
			inputDir: 'tpl/web', outputDir: 'cfg',
			files: [
				(generateRest ? 'web.xml.tpl' : '')]]  ],
	'gsql' : [
		'baseDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [
				'gsql/Dao.groovy.tpl', 'GenericDao.java.tpl', 'GenericPK.java.tpl',
				'GenericDaoExt.java.tpl']],
		'entityDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: ['${className}Dao.java.tpl', "gsql/\${className}Dao${binding['implementation']}Impl${StringUtils.capitalize(binding.useDb)}.groovy.tpl"]],
		'config':  [
			inputDir: 'tpl/gsql', outputDir: 'cfg',
			files: [
				(generateOrmCfg 		? "gsql-${binding.useDb}.properties.tpl" : '')]],
		'web-util': [
			inputDir: 'tpl/gsql', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [(generateOsivFilter 	? 'GSqlOsivFilter.java.tpl' : '')]],
		'java-util': [
			inputDir: 'tpl/gsql', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}/util",
			files: ['PropertyLoader.java.tpl' ]],
		'rest': [
			inputDir: 'tpl/rest', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [
				(generateRest ? '${className}Application.java.tpl' : ''), 
				(generateRest ? '${className}Service.java.tpl' : '')]],
		'swagger-ui': [
			inputDir: 'tpl/rest/swaggerui', outputDir: 'web',
			files: [
				(generateRest && generateSwaggerUi ? 'swaggerui.zip.unzipme' : ''),
				(generateRest && generateSwaggerUi? 'index.html.tpl' : '')]],
		'web':  [
			inputDir: 'tpl/web', outputDir: 'cfg',
			files: [
				(generateRest ? 'web.xml.tpl' : '')]] ],
			
	'ormlite' : [
		'baseDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [
				'ormlite/DBHelper.java.tpl', 'ormlite/DBHelperImpl.java.tpl', 'GenericDao.java.tpl', 
				'GenericPK.java.tpl', 'GenericDaoExt.java.tpl', "ormlite/GenericDaoImpl.java.tpl",
				'ormlite/${className}DaoExt.java.tpl', 'ormlite/${className}DaoExtImpl.java.tpl',
				'ormlite/DaoHelper.java.tpl' ]],
		'entityDao': [
			inputDir: 'tpl', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: ['${className}Dao.java.tpl', "ormlite/\${className}DaoImpl.java.tpl"]],
		'util': [ 
			inputDir: 'tpl/ormlite', outputDir: "src/${binding.packageName.replaceAll('[.]', '/')}",
			files: [ 'DBConfigUtil.java.tpl' ]] ]]


showRunInfo(
	outputPackage, classForDao, superClassForDao, 
	includeSuperFields, key.fieldName, 
	binding.isAbstract, binding.fieldList, 
	osivDao, useOrm, 
	generateRest, restFormat, generateSwaggerUi, 
	appServerHost, appServerPort, warName,
	verboseOutput)

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

// TODO unpack .zip files with extension .zip.unzipme
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
				
				if (inputFile.endsWith('.zip.unzipme')) {
					
					try {
						def ant = new AntBuilder()
						ant.unzip( 
							src: "${baseOutputDir}/${outputDir}/${outputFile}", 
							dest: "${baseOutputDir}/${outputDir}", 
							overwrite: true)
						
						FileUtils.deleteQuietly new File("${baseOutputDir}/${outputDir}/${outputFile}")
					} catch (Exception ex) {
						if (verboseOutput) println "unzip failed!!!"
						ex.printStackTrace()
					}
				}
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
			element.name.startsWith('get') && StringUtils.uncapitalize(element.name.substring(3)) == name},
			skipEntityAnnotation=true)
	
}

def findIdUsingAnnotation(fqClassName) {	
	
	findIdUsingPredicate(fqClassName, {element -> element.annotations*.annotationType().name.find { annotation -> annotation == 'javax.persistence.Id' }})

}

// TODO watch-out for generics types
def findIdUsingPredicate(fqClassName, predicate, skipEntityAnnotation=false) {
	def clazz = Class.forName(fqClassName)
	def idField = null
	
	if (skipEntityAnnotation || clazz.annotations.find { it.annotationType().name == 'javax.persistence.Entity' }) {
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
	
	def templateUrl = getClass().getResource(templateName)
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
			
			isSubType = ClassUtils.getCanonicalName(subType).startsWith('java.lang') ? false : true
			if (!isSubType) {
				isSubType = ClassUtils.getCanonicalName(subType).startsWith('java.util.Date') ? false : true
			}
			
		} else {
			if (!fqTypeAsString.startsWith('java.lang') && !fqTypeAsString.startsWith('java.util.Date')) {
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
			
			def fieldName = "${StringUtils.uncapitalize(it.name.substring(3))}"
			def field_name = fieldName.split('(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])').join('_').toLowerCase()
			
			if (field) {
				if (isSubType) {
					fields.add([fieldName: fieldName, field_name: field_name, fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}", fieldId: [fieldName: field?.name, fieldType: field?.type], fieldList: getFields(Class.forName(subType), field?.name, fqClassName)])
				} else {
					fields.add([fieldName: fieldName, field_name: field_name, fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}", fieldId: [fieldName: field?.name, fieldType: field?.type]])
				}
			} else {
				if (isSubType) {
					fields.add([fieldName: fieldName, field_name: field_name, fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}", fieldId: [fieldName: field?.name, fieldType: field?.type], fieldList: getFields(Class.forName(subType), field?.name, fqClassName)])
				} else {
					fields.add([fieldName: fieldName, field_name: field_name, fieldType: "${typeAsString}", fqFieldType: "${fqTypeAsString}"])
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
def showRunInfo(outputPackage, 
	classForDao, superClassForDao, includeSuperFields, keyField, isAbstract, fields, 
	osivDao, useOrm, generateRest, restFormat, generateSwaggerUi, 
	appServerHost, appServerPort, warName,
	verboseOutput) {
	
	println "Entity class: ${classForDao.name}${isAbstract ? ' (abstract)' : ''}${includeSuperFields && superClassForDao.name != 'java.lang.Object' ? ' (+' + superClassForDao.name + ')' : ''}"
	println "Output package: ${outputPackage}"
	println "Orm technology: ${useOrm}"
	println "Generate rest service [RestEasy]: ${generateRest ? 'yes' : 'no'}"
	if (generateRest) {
		println "Rest service format: ${restFormat}"
		println "Generate Swagger UI: ${generateSwaggerUi ? 'yes' : 'no'}"
		println "Deploy on: http://${appServerHost}:${appServerPort}/${warName}"
	}
	println "Entity key field: ${keyField}"
	println ""
	println "Attributes found: (* - key field)"
	fields.each { field ->
		def props = []
		if (field.fieldName == keyField) props.add('(*)')
		println "\t${field.fieldType} ${field.fieldName} ${props.join(' ')}" 
	}
	print "Generating code ${osivDao ? 'using osiv filter, see http://community.jboss.org/wiki/OpenSessioninView' : ''}"
	println ""
	if (verboseOutput)
		println ''
	else 
		print '...'
}


def showUsage() {
	println """
Please specify the following parameters:
\t-fq-class-name=<full qualified class name of the entity from which generate the Dao code>
\t[-key-field-name=<key field of the entity>]
\t[-output-package=<package of the generated dao code>]
\t[-include-super-fields]
\t[-osiv-dao]
\t[-spring-dao]
\t[-use-ehcache]
\t[-use-db=<db name> select the specific db - default: mysql
\t\tAvailable dbs: mysql, postgres
\t[-generate-orm-cfg]
\t[-generate-spring-cfg]
\t[-generate-ehcache-cfg]
\t[-generate-dao-base-classes]
\t[-generate-osiv-filter] see http://community.jboss.org/wiki/OpenSessioninView
\t[-use-orm=<orm technoly to use>] technology configuration - default: hibernate
\t\tAvailable orms: hibernate, mybatis, gsql, ormlite (android)
\t[-verbose] verbose output
\t[-generate-rest] generate rest ws
\t[-use-rest-format=<data format>] default json+xml
\t\tAvailable format: json, xml, json+xml
\t[-generate-rest-swagger-ui]
\t[-host=<host name or ip>] deploy app server hostname - default localhost
\t[-port=<host port>] deploy app server port - default 8080
\t[-war-name=<name of war>] default <class-name>RestWs
"""
}
