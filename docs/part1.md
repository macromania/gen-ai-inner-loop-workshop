# Part 1: Programming Environment Setup

This section will guide you through the setup of the python development environment using VSCode and Jupyter notebooks. The section also covers following topics:

- Overview of **Python 3** versions and featured offered
- Setting up **Python 3.9+** environment using virtual environments
- Setting up Jupyter notebooks
- VSCode extensions for Python development

## **Python 3** versions and featured offered

- **Python 3.0** (2008): Introduced significant changes like print as a function, integer division returning a float, and Unicode strings.
- **Python 3.1** (2009): Introduced an ordered dictionary type, a new I/O system, and improved the Python standard library.
- **Python 3.2** (2011): Introduced the concurrent.futures module for parallel tasks, the argparse module for command-line arguments, and a stable ABI for extension modules.
- **Python 3.3** (2012): Introduced the yield from syntax for generator delegation, the venv module for creating virtual environments, and the faulthandler module for debugging crashes.
- **Python 3.4** (2014): Introduced the asyncio module for asynchronous I/O, the enum module for enumeration types, and the pathlib module for object-oriented filesystem paths.
- **Python 3.5** (2015): Introduced the async and await syntax for asynchronous programming, the @ operator for matrix multiplication, and type hints.
- **Python 3.6** (2016): Introduced f-strings for easier string formatting, underscores in numeric literals for improved readability, and secrets module for generating cryptographically strong random numbers.
- **Python 3.7** (2018): Introduced data classes for easier creation of classes to store values, and the built-in breakpoint() function for debugging.
- **Python 3.8** (2019): Introduced the walrus operator (:=) for assignment expressions, positional-only parameters, and the Protocol class to define structural type interfaces.
- **Python 3.9** (2020): Introduced the merge (|) and update (|=) operators for dictionaries, the removeprefix() and removesuffix() string methods, and the zoneinfo module for IANA time zones.
- **Python 3.10** (2021): Introduced structural pattern matching (match-case statements), the Parental Scope References in Named Expressions (PEP 657), and error locations in tracebacks.

> **Note**: Python 3.9+ is recommended for this workshop. Python 3.9 is the most widely used version of Python 3. It is the latest version of Python 3 and has many new features and optimizations. Most of the Azure SDKs and libraries are compatible with Python 3.9+.

## Virtual Environments in Python

Virtual environments in Python are isolated environments where you can install packages and dependencies for a specific project without affecting the global Python installation or other projects. This is especially useful when different projects require different versions of the same package.

There are several virtual environment managers available for Python, each with its own set of features and benefits:

- **venv**: A built-in module in Python 3 for creating virtual environments.
- **virtualenv**: A third-party package for creating virtual environments. It is compatible with both Python 2 and Python 3.
- **conda**: A package and environment manager provided by Anaconda, Inc. It is designed for data science and machine learning workflows.
- **pyenv**: A simple Python version management tool that allows you to easily switch between multiple versions of Python.
- **pipenv**: A package manager for Python that combines the functionality of pip and virtualenv in a single tool.
- **poetry**: A modern dependency management tool for Python that allows you to declare and manage project dependencies in a simple and consistent way.

> For this workshop and code samples, we will use `venv` which is a built-in module and has no external dependencies.

### Using `venv` to Create a Virtual Environments

In Python 3, you can create a virtual environment using the built-in `venv` module. Like in other programming languages, a virtual environment is a self-contained directory tree that contains a Python installation for a particular version of Python, plus a number of additional packages. All the packages that you install in this environment will be isolated from the global Python environment.

> Most of the code samples and projects follow a convention calling their virtual environment directory `.venv`. This is a common convention, but you can name your virtual environment directory anything you like.

### Excercise: Create a Virtual Environment

To create a virtual environment using `venv`, follow these steps:

1. Open a terminal or command prompt.
2. Navigate to your project directory.
3. Run the command `python3 -m venv .venv` (where "env" is the name of your virtual environment).

```bash
python3 -m venv env
```

This will create a new directory called `env` in your project directory. This directory will contain a copy of the Python interpreter, the standard library, and various supporting files.

Navigate to your project directory in the terminal.
Run the command python3 -m venv env (where "env" is the name of your virtual environment).
Activate the virtual environment. On Windows, run env\Scripts\activate. On Unix or MacOS, run source env/bin/activate.
Now you can install packages using pip install that are local to this environment.
When the virtual environment is activated, your shell prompt will show the name of the environment. Any packages you install while the environment is activated will be installed in that environment, not globally.

To deactivate the virtual environment and return to your global Python environment, simply run the command deactivate.
