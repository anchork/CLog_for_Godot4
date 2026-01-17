# CLog for Godot 4


![Godot Demo](media/godot_demo.png)

CLog is a simple logging utility for Godot 4. It provides enhanced console output with support for source code links, colors, and performance timers.

## Compatibility
Supports Godot 4.5 or later.

## Features
- **Source Navigation**: Clicking on a log entry in the console will take you directly to the source code.
- **Node Link**: Passing a `Node` or `NodePath` creates a clickable link that selects the node in the Scene tree.
- **Rich Text Output**: Supports colored logs and formatting.
- **Performance Timers**: Measure execution time with starting, ending, and canceling timers.

*Note: Source navigation is implemented using a workaround. If navigation stops working, please try restarting the plugin or the editor.*

In IDEs such as VS Code, you can jump to the source code by using **Ctrl + Click** on the file path. However, as expected, the Node link jump feature does not work in VS Code.

**VS Code Display Example:**
![VS Code Demo](media/vscode_demo.png)

## Installation

### Using the Godot Asset Library

Open the **AssetLib** tab at the top of the Godot editor, search for **CLog**, and download it. Then go to Project → Project Settings → Plugins tab, and enable CLog.

### Installing from a GitHub Release

Download the latest release from the [GitHub releases page](https://github.com/anchork/CLog_for_Godot4/releases).
In the Godot editor, open the **AssetLib** tab, click **Import**, and select the downloaded `clog-<version>.zip` file. Then go to Project → Project Settings → Plugins tab, and enable CLog.

## Usage

### Standard Output
Outputs a simple message to the console.
```gdscript
CLog.o("Some message")
CLog.o("Value A:", 100, "Value B:", true)
```

### Error Logging
Outputs an error message with a highlighted style.
```gdscript
CLog.e("An error occurred")
```

### Warning Logging
Outputs a warning message.
```gdscript
CLog.w("This is a warning")
```

Both `CLog.e` and `CLog.w` internally call `push_error()` and `push_warning()` respectively. This ensures they appear in Godot's Debugger panel and are recorded in the built-in engine logs.

### Verbose Logging
Outputs a message with a stack trace without an error.
```gdscript
CLog.v("This is a verbose message")
```

### Custom Color Output
Outputs a message using a specific color.
```gdscript
CLog.c(Color.ORANGE, "Custom orange message")
```

### Once (Log once by key)
Outputs a message only once for a specific unique key. This is ideal for logging events inside `_process()` or loops without flooding the console.
```gdscript
func _process(_delta: float):
    # This will be printed only once for the key &"start_processing"
    CLog.once(&"start_processing", "Process loop started")
```


### Performance Timers
Measure how long a specific process takes.
```gdscript
# Start a timer
var id = CLog.timer_start("Process Name")

# End the timer and print elapsed time
CLog.timer_end(id)

# Cancel the timer without printing
CLog.timer_cancel(id)
```

### Release Mode Logging
By default, `CLog` suppresses output in release builds for performance and security. You can toggle this behavior using the `disable_output_on_release_mode` property.

```gdscript
# Enable logging even in release mode
CLog.disable_output_on_release_mode = false
```
