# SwiftyShellScript
[![License: MIT](https://img.shields.io/github/license/gregorFeigel/SwiftyShellScript)](https://github.com/gregorFeigel/SwiftyShellScript/blob/main/LICENSE)
![Version: v](https://badgen.net/github/release/gregorFeigel/SwiftyShellScript)
![Plattform: v](https://badgen.net/badge/plattform/macOS|Linux/gray)
![Swift: v](https://badgen.net/badge/swift/5/orange)

A package for creating, rendering, implementing and running dynamic shell script templates in Swift with leaf-inspired syntax.<br/>
Modify shell scripts dynamically with Swift and use shell script functions in your swift code.

#### Features

- [x] use leaf-inspired syntax tags such as #(var), #func(Input) and custom ones to create dynamic shell script templates.
- [x] export the rendered script or run it directly
- [x] embed shell script functions in swift code
- [x] automatically index and embed shell scripts from the bundle or a folder
- [x] run scripts and commands with a timeout handler 
- [x] get and modify file infos


#### Table of Contents

- [Shortoverview](#short-overview)
- [Installation](#installation)
- [Create dynamic script templates](#create-dynamic-script-templates)
    - [Variable](#variable)
    - [Function](#function)
    - [Custom tag](#custom-tag)
- [Render scripts](#render-scripts)
    -  [Export the rendered script](#export-the-rendered-script)
    -  [Run the rendered script](#run-the-rendered-script)
- [Run any shell script and command](#run-any-shell-script-and-command)  
    - [Default](#default)
    - [Error only](#error-only)
    - [True False](#true-false)
    - [Realtime output](#realtime-output)
- [Embed shell script functions in swift](#embed-shell-script-functions-in-swift)
- [Get and modify file info](#get-and-modify-file-info)

## Short overview 

### Render and run dynamic shell script templates with swift:

shell script: 
```
#!/bin/sh
echo "this is a dynamic shell script"
ls /Documents/testFileName-#(test).txt // variable test
touch fileWithCreationDate-#getDate(yyyy-MM-dd).txt // function getDate with input "yyyy-MM-dd"
§§hi // custom tag §§hi
exit
```

in swift:
```swift
import SwiftyShellScript

    /* rendering scripts */
    
let a = Item(identifier: "test", input: "this is a test variable", taskType: .variable)
let b = Item(identifier: "§§hi", input: "this is a custom tag", taskType: .custom)
let c = Item(identifier: "getDate", function: { input in input.doSomething() }, taskType: .function)
let renderSet = [a, b, c]

let script = shellScriptRenderer("/Users/admin/Documents/test.sh")
script.render(renderSet)

// export the rendered script 
script.exportTo("/Users/admin/Documents/renderedTest.sh")
script.chmod(to: 755, .int)

// run the rendered script automatically in tmp dir
script.timeout = 300 // if the script is not done in 5 min it will be killed 
let output = script.runScript() 
print(output.standardOutput)

```

### embed shell script functions in your swift code

shell script: 
```
# /* SwiftyShellScript Bridge
#
# - function: greet
#
# */End
#!/bin/sh
greet() {
echo "Hi $1"
}
"$@"
exit
```

in swift:
```swift
ShellScripts("pathToScriptFolder").function("greet", param: "Thomas") // returns "Hi Thomas"

// add a timeout
ShellScripts("pathToScriptFolder").function("greet", param: "thomas", timeout: 20) // returns "Hi Thomas"
```

### get file informations and modify them:
```swift
    /* working with files */

let info = fileInfo("/Users/admin/Documents/test.sh")
info.fileSize(.byte))
info.groupOwnerAccountName()
info.posixPermissions(as: .int)
info.ownerAccountName()
...
info.isWritable()
info.isSymbolicLink()

// modify
let file = modify("/Users/admin/Documents/test.sh")
file.rename(to: renamed.txt)
file.chmod(755, .int)
```
 

## Installation

### Swift Package Manager
Add SwiftyShellScript as a dependency to your `Package.swift`:

```swift
dependencies: [
.package(url: "https://github.com/gregorFeigel/SwiftyShellScript.git", from: "0.0.3") // .branch("main")
]
```


## Create dynamic script templates

With the leaf-inspired syntax you can easily create dynamic script templates. 
The three tag types (var, func and custom) are explained below:


#### Variable

A variable is defined by using #(yourVarName) in your shell script. 

```
#!/bin/sh
#(hello) // variable hello
touch test-#(fileName).txt // variable fileName
exit
```

To initiate your variable, create a render element with the task type .variable: <br/>
The variable name in this example is "hello" and will be replaced with "this is a test variable".

```swift
let a = Item(identifier: "hello", input: "#this is a test variable", taskType: .variable)
let b = Item(identifier: "fileName", input: "\(NSUserName()!)", taskType: .variable)
```
rendered result:
```
#!/bin/sh
#this is a test variable
touch test-admin.txt
exit
```



#### Function

A function is defined by using #yourFunction(functionInput) in your shell script.

```
#!/bin/sh
echo "#getDate(yyyy-MM-dd HH:mm:ss)" // function "getDate" with input "yyyy-MM-dd HH:mm:ss"
exit
```

To initiate your function, create a render element with the task type .function: <br/>
The function name in this example is "getDate" and will be replaced with the result (String) of your function you define in the funtion init.

```swift
let a = Item(identifier: "getDate", function: { input in input.getDate() }, taskType: .function)

extension String {
    
    func getDate() -> String {
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = self
        return dateFormat.string(from: Date()) + " - input format:" + self
        
    }
    
}
```

rendered result:
```
#!/bin/sh
echo "2021-06-24 10:34:04 - input format: yyyy-MM-dd HH:mm:ss"
exit
```

#### Custom 

With the custom tag you can define anything and replace it with the input parameter.

```
#!/bin/sh
echo "§§hi" // custom tag §§hi
exit
```
To initiate your custom tag, create a render element with the task type .custom: <br/>
The custom tag in this example is "§§hi" and is replaced by "this is a custom tag".

```swift
let a = Item(identifier: "§§hi", input: "this is a custom tag", taskType: .custom)
```
rendered result:
```
#!/bin/sh
echo "this is a custom tag"
exit
```
 

## Render scripts

To render the script, you need to create a render set and then pass the render set into the renderer:

```swift

// Create the render set by simply adding the individual elements together into an array:

let a = Item(identifier: "test", input: "this is a test variable", taskType: .variable)
let b = Item(identifier: "test2", input: "this is a second test variable", taskType: .variable)
let renderSet = [a, b])


// select the script
let script = shellScriptRenderer("/Users/admin/Documents/test.sh")

// render the script with the render set
script.render(renderSet)

```
 

### Export the rendered script

Export the rendered script to a new path.
With the options .force and .sensitive you can decide whether the export job should overwrite the file, if it already exists or not. It is set to .sensitive by default.

```swift
let script = shellScriptRenderer("/Users/admin/Documents/test.sh")
script.render(renderSet)
script.exportTo("/Users/admin/Documents/renderedTest.sh")

// force overwriting 
script.exportTo("/Users/admin/Documents/renderedTest.sh", overwrite: .force)

// sensitive 
script.exportTo("/Users/admin/Documents/renderedTest.sh", overwrite: .sensitive)


/* directly change posix permissions */

// input as int
script.chmod(to: 755, .int)

//input as octal number
script.chmod(to: 0o755, .octalNumber)

//input as octal number
script.chmod(to: 493, .octalNumber)
```


### Run the rendered script

Run the rendered script directly after rendering.
The timeout option will force terminate the process if the timeout is reached. 
The timeout value is set to 300 sec by default. If you want to disable it, you can set the time to .infinity. 
 
 ```swift
 
 let script = shellScriptRenderer("/Users/admin/Documents/test.sh")
 script.render(renderSet)
 script.timeout = 60 // time in seconds
 script.launchPath = "/bin/sh" // by default set to /bin/bash
 script.arg = "-e" // by default set to -c
 let output = script.runScript()
 
 print(output.processTime)  // Double - time the process took to complete 
 print(output.timeoutInterrupt) // Bool - true if timeout terminated the process 
 print(output.error) // String - error while launching the process 
 print(output.terminationStatus) // Int32 - process termination status
 
 // shell script output split into standard error and standard output
 print(output.standardError)  
 print(output.standardOutput)
 
 ```
 
 ## Run any shell script and command

### Default

Run script and commands and get all informations back.

```swift
let script = runScript(scriptPath: "/Users/admin/Documents/test.sh")
script.timeout = 30
script.launchPath = "/bin/sh" // by default set to /bin/bash
script.arg = "-e" // by default set to -c
let output = script.runDefault()

print(output.processTime)  // Double - time the process took to complete 
print(output.timeoutInterrupt) // Bool - true if timeout terminated the process 
print(output.error) // String - error while launching the process 
print(output.terminationStatus) // Int32 - process termination status

// shell script output split into standard error and standard output
print(output.standardError)  
print(output.standardOutput)
```


### Realtime output 

 Run script and commands and get the output printed in realtime.
 ! This does only print the output and returns nothing !
 
 ```swift
 let script = runScript(scriptPath: "/Users/admin/Documents/test.sh")
 script.timeout = 30
 script.launchPath = "/bin/sh" // by default set to /bin/bash
 script.arg = "-e" // by default set to -c
 script.shellPrintRealTime()
 ```
 

### True False 

Run script and commands. If the standard error is empty the return value is true 

```swift
let script = runScript(scriptPath: "/Users/admin/Documents/test.sh")
script.timeout = 30
script.launchPath = "/bin/sh" // by default set to /bin/bash
script.arg = "-e" // by default set to -c
let output = script.shellBool()
print(output)
```


 ### Error only
 Run script and commands and only get the standard error output.
 
 ```swift
 let script = runScript(scriptPath: "/Users/admin/Documents/test.sh")
 script.timeout = 30
 script.launchPath = "/bin/sh" // by default set to /bin/bash
 script.arg = "-e" // by default set to -c
 let output = script.shellErrorsOnly()
 print(output)
 ```


 
 
 ## Embed shell script functions in swift
 
 Easily use your shell script functions inside swift.
 To use shell script functions in swift you need to create a bridge header in your shell script, that registers the public available functions from your script.  
 ! The function names must be unique. !
 
 ````
 # /* SwiftyShellScript Bridge
 #
 # - function: greet //the name of the function 
 # - function: getData //the name of the function 
 #
 # */End 
 ````
 
 If you have an app with a bundle, just create in your app bundle a folder named "shellScripts" and move all your scripts in there - you can use sub folders as well. 
 All the scripts with the extension .sh in this folder will be automatically indexed and the function addressed to the correct script.
 
 ```swift
 let result = ShellScripts().function("greet", param: "Thomas")
 ````
 
 If your project has no bundle, just insert the folder dir of the folder containing all your scripts.
 
 ```swift
 let result = ShellScripts(URL(fileURLWithPath: "/Users/admin/Scripts")).function("greet", param: "Thomas")
 ````
 
### example

shell script:
```
# /* SwiftyShellScript Bridge
#
# - function: greet 
# - function: say 
#
# */End 
#!/bin/bash

function greet()
{
    echo "Hi $1"
}

say()
{
    echo "$1"
}

"$@"
exit
```
 
 in swift: 
 
 ```swift
 var result = ShellScripts().function("greet", param: "Thomas") // returns Hi Thomas
     result = ShellScripts().function("say",   param: "\"this is a test\"") // returns this is a test
 ````
 


## Get and modify file info

get file info: 
return values are optional - returns nil if files does not exist, or the value can't be read.  

```swift
let info = fileInfo("/Users/admin/Documents/test.sh")
info.isExecutable() // -> Bool?
info.isReadable() // -> Bool?
...
info.ownerAccountName() //-> String? 
```

modify file info: 

```swift
let info = modify("/Users/admin/Documents/test.sh")
info.chmod(755, .int)
info.rename(to: "")
```
