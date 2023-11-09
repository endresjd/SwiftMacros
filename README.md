# macros
John Endres' (Macplugins) macro collection.

Macros defined:

1. **buildURLRequest** -- Builds an URLRequest based on a string-based url.
2. **OSLogger** -- Adds a logger instance to a class or a struct.  Shows how to add a member to a class or a struct

# **Usage**

## buildURLRequest
### Create a GET request with no headers

    if let request = #buildURLRequest("https://www.google.com") {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

### Create a PUT request with no headers

    if let request = #buildURLRequest("https://www.apple.com", method: "PUT") {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

### Create a POST request with headers

    if let request = #buildURLRequest("https://www.macplugins.com", method: "POST", headers: ["one":"two", "three":"four"]) {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

### Create using runtime values

    let url = "https://www.johndoe.com"
    let method = "GET"
    let headers = ["first":"John", "last":"Doe"]

    if let request = #buildURLRequest(url, method: method, headers: headers) {
        dumpURLRequest(request)
    }
    
## OSLogger

This shows a struct with three loggers attached that show some of the ways to use it.  All of the parameters are not required.  The method defined in this struct are using the loggers that were added by the attached macros.  The default subsystem used here is the current bundleidentifier for the target if it can be determine.

**IMPORTANT**

The added properties require an added import: `import os` at the top of your file.  Otherwise you will get a compilation error.

	import os
	
	let subsystem = "ClientSubsystem"
	let category = "ClientCategory"
	
	@OSLogger
	@OSLogger("clientLogger", subsystem: subsystem, category: category)
	@OSLogger("categoryLogger", subsystem: "Client", category: "Other")
	@OSLogger("subsystemLogger", subsystem: "subsystem")
	@OSLogger("fullLogger", subsystem: "Example sub-system", category: "example category")
	struct ExampleStruct {
	    func example(_ message: String) {
	        logger.debug("a debug message")
	        clientLogger.error("CLIENT LOGGER!")
	        categoryLogger.debug("categoryLogger debug message")
	        subsystemLogger.info("a subsystem message: \(message, privacy: .private)")
	        fullLogger.notice("Notice from fullLogger")
	    }
	}
