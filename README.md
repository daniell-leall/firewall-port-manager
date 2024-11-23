# Firewall Port Manager Tool

## Overview

**Firewall Port Manager Tool** is a command-line utility designed to simplify the management of firewall rules on Windows systems. This tool provides a user-friendly interface for tasks such as opening and closing ports, listing active rules, and deleting rules. It is ideal for users who need quick and efficient control over their firewall settings without the need for complex commands.

## Features

- **Open a Port**: Easily open ports with support for TCP, UDP, or both protocols.
- **Close a Port**: Remove specific firewall rules for a given port and protocol.
- **List Open Ports**: View all currently open ports and their corresponding firewall rules.
- **Temporary Rules**: Open ports for a limited time, automatically closing them after the specified duration.
- **Delete All Rules**: Clean up all firewall rules created by the tool with a single command.
- **Admin Check**: Ensures the script is executed with administrative privileges for proper functionality.

## Requirements

- **Operating System**: Windows (with `netsh` command available).
- **Privileges**: Must be run as an administrator.
- **Environment**: Windows Command Prompt with UTF-8 encoding support.

## Installation

1. Clone or download the repository to your local machine.
2. Ensure the script file (`firewall-port-manager-windows.bat`) has execution permissions.
3. Run the script in Command Prompt with administrative privileges.

## Usage

1. Open Command Prompt as an administrator.
2. Navigate to the folder containing the script.
3. Run the script by typing:
   ```cmd
   firewall-port-manager-windows.bat
