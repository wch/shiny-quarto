# Shiny Extension For Quarto

_TODO_: Add a short description of your extension.

## Installing

```bash
quarto add wch/shiny-quarto
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

Also make sure to install htmltools and Shiny for Python from development branches:

```bash
pip install git+https://github.com/posit-dev/py-htmltools.git@html-text-doc#egg=htmltools
pip install git+https://github.com/posit-dev/py-shiny.git@quarto-ext#egg=shiny
```

## Using

_TODO_: Describe how to use your extension.

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

To run the example, clone this repository, run the installation steps above, and then run:

```bash
quarto render example.qmd  &&  shiny run app.py
```