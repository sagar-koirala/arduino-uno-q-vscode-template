# Arduino UNO Q VS Code Template

This is a template project for developing Arduino UNO Q applications using the Command-Line Interface (CLI) and VS Code, completely bypassing the default App Lab.

## Quick Start

1. **Configure IP:** Open `.vscode/settings.json` and set your `arduino.ip` to match the IP address of your Arduino UNO Q board.
2. **Setup Connection:** Run the `UNO-Q: Setup SSH Connection` task to configure passwordless SSH if you haven't already.
3. **Deploy:** Use `Ctrl + Shift + B` (or run the `UNO-Q: Deploy and Start App` task) to compile, copy, and run your project on the UNO Q.
4. **Monitor:** A split terminal will automatically open showing the live log output from the Python interpreter on the board.

## Renaming Your Project

Since this is a template, you'll likely want to rename the project after cloning. To rename your project safely:

1. **Rename the Root Folder:** Rename this folder (e.g., from `arduino-uno-q-vscode-template` to `my-awesome-project`) in your file explorer *before* opening it in VS Code. 
   - *Why?* The deployment tasks in `.vscode/tasks.json` dynamically use `${workspaceFolderBasename}`, meaning the folder on the Arduino UNO Q will be created automatically matching your new folder name!
2. **Update `app.yaml`:** Open the `app.yaml` file in the root directory and change the `name:` and `description:` fields to match your new project.
3. **Leave `sketch/` and `python/` filenames alone:** As per the Arduino UNO Q documentation, the system explicitly looks for `python/main.py`, `sketch/sketch.ino`, and `sketch/sketch.yaml`. Do **not** rename these specific files!

## Collaboration & Syncing Changes

The task **`UNO-Q: Pull App Changes (SCP)`** is designed for scenarios where two people are collaborating directly on the same board. 

⚠️ **WARNING:** Using this task will constructively **overwrite** your local workspace's `python/`, `sketch/`, `assets/`, and `app.yaml` with the contents currently living in the board's directory. 
Only use this task if you are certain you want to merge/download the other developer's live changes onto your machine. Always maintain git version control as a primary backup.

## Adding Files and Folders
Current deployment logic explicitly synchronizes the base `app.yaml` and the `assets`, `python`, and `sketch` folders natively. If you decide to add other folders (like `data` or `config`) to your project root, make sure to add them to both the **Deploy** and **Pull** tasks' `args` list inside `.vscode/tasks.json`.