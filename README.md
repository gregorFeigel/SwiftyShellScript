# SwiftyShellScript
[![License: MIT](https://img.shields.io/github/license/gregorFeigel/SwiftyShellScript)](https://github.com/gregorFeigel/SwiftyShellScript/blob/main/LICENSE)
![Version: v](https://badgen.net/github/release/gregorFeigel/SwiftyShellScript)
![Plattform: v](https://badgen.net/badge/plattform/macOS|Linux/gray)
![Swift: v](https://badgen.net/badge/swift/5/orange)

A package for rendering, implementing and running dynamic shell scripts in Swift with leaf-inspired syntax.<br/>
Modify shell scripts dynamically with Swift and use shell functions in your swift code.

#### Features

- [x] use leaf-inspired syntax tags such as #(var), #func(Input) and custom ones to create dynamic shell scripts.
- [x] export the rendered script or run it directly
- [x] embed shell script functions in swift code
- [x] automatically index and embed shell scripts from the bundle or a folder
- [x] run scripts and command with a timeout handler 
- [x] get and modify file infos


#### Table of Contents

- [Shortoverview](#short-overview)
- [Installation](#installation)
- [Create dynamic scripts](#create-dynamic-scripts)
        - [Variable](#variable)
        - [Function](#function)
        - [Custom tag](#custom-tag)
- [Render scripts](#render-scripts)
- [Embed shell scripts in swift](#embed-shell-scripts-in-swift)
- [Get and modify file info](#get-and-modify-file-info)

## Short overview 

shell script: 
```
#!/bin/sh
echo "this is a dynamic shell script"
ls /Documents/testFileName-#(test).txt // variable test
touch fileWithCreationDate-#getDate(yyyy-MM-dd).txt // function getDate with input "yyyy-MM-dd"
§§hi // custom tag §§hi
exit
```

### Render and run dynamic shell scripts with swift 
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
#!/bin/sh
greet() {
echo "Hi $1"
}
"$@"
exit
```

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
.package(url: "https://github.com/gregorFeigel/SwiftyShellScript.git", from: "0.0.2") // .branch("main")
]
```

## Usage

### Create a render set

To render the script, you need to create a render set.
Therefor you have three task type options:

#### Variable

A variable is defined by using #(yourVarName) in your shell script.

```
#!/bin/sh
#(hello) // variable hello
exit
```

To initiate your variable, create a render element with the task type .variable: <br/>
The variable name in this example is "hello" and will be replaced with "this is a test variable".

```swift
let a = Item(identifier: "hello", input: "this is a test variable", taskType: .variable)
```


#### Function

A function is defined by using #yourFunction(functionInput) in your shell script.

```
#!/bin/sh
#getDate(yyyy-MM-dd HH:mm:ss) // function "getDate" with input "yyyy-MM-dd HH:mm:ss"
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
The rendered script now looks like this:

```
#!/bin/sh
2021-06-24 10:34:04 - input format: yyyy-MM-dd HH:mm:ss
exit
```

#### Custom 

With the custom tag you can define anything and replace it with the input parameter.

```
#!/bin/sh
§§hi // custom tag §§hi
exit
```
To initiate your custom tag, create a render element with the task type .custom: <br/>
The custom tag in this example is "§§hi" and is replaced by "this is a custom tag".

```swift
let a = Item(identifier: "§§hi", input: "this is a custom tag", taskType: .custom)
```

#### Create the render set

Create the render set by simply putting the individual elements together into an array:

```swift
let a = Item(identifier: "test", input: "this is a test variable", taskType: .variable)
let b = Item(identifier: "test2", input: "this is a second test variable", taskType: .variable)
let renderSet = [a, b])
```


### Choose the script 

Open the script render by passing the file path: 

```swift
let script = shellScriptRenderer("/Users/admin/Documents/test.sh")
```

### Render the script 

Render the script by passing the render set array into the renderer.

```swift
let script = shellScriptRenderer("/Users/admin/Documents/test.sh")
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
```

### Change file permissions 

Change file permissions by using .chmod(to: ).

```swift
let script = shellScriptRenderer("/Users/admin/Documents/test.sh")
script.render(renderSet)
script.exportTo("/Users/admin/Documents/renderedTest.sh", overwrite: .sensitive)

// input as int
script.chmod(to: 755, .int)

//input as octal number
script.chmod(to: 0o755, .octalNumber)

//input as octal number
script.chmod(to: 493, .octalNumber)
```


## script Info

#### check if file exists:

```swift
let info = scriptInfo(path: /Users/admin/Documents/test.sh")
info.checkIfFileExits() // -> Bool
```
