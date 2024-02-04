# Virtual Environment Management Script

This script is designed to facilitate the creation, deletion, and management of Python virtual environments. Additionally, it provides functionality for updating packages and listing installed packages within an environment.

## Usage

### Options

- `-c`: Check existing environments.
- `-e <name>`: Specify the environment name.
- `-f <file>`: Specify the requirements file for environment creation.
- `-l`: List installed packages in an environment.
- `-u`: Update packages.
- `-d`: Delete an environment.

### Examples

#### Check Existing Environments

```bash
./env.sh -c
```

#### Create a New Environment

```bash
./env.sh -e myenv -f requirements.txt
```

#### List Packages in an Environment

```bash
./env.sh -e myenv -l
```

#### Update Packages

```bash
./env.sh -u
```

#### Delete an Environment

```bash
./env.sh -e myenv -d
```

### Activating Environments

After creating an environment, activate it using the following command:

```bash
source path/to/environment/bin/activate
```

To deactivate the environment, simply run:

```bash
deactivate
```

Remember to activate the environment before installing or using Python packages within it.
