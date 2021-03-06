# Ordinary Merge

Vim's git client

![Screenshot](screenshots/Screenshot_2022-07-16_14-53-38.png)

## Install

TDB

## Usage

Load/Open main dashboard

```
:OrdinaryMerge
```

### Key Maps per Window

- Branches List:
  - `<Enter>` - Checkout the branch under the cursor
  - `<c>` - Navigates to Commits List window
  - `<f>` - Navigates to Commit Files window
- Commits List:
  - `<Enter>` - Render details and files related to the commit under the cursor
- Commit Details:
  - `<b>` - Navigates to Branches List window
  - `<c>` - Navigates to Commit List window
- Commit Files:
  - `<b>` - Navigates to Branches List window
  - `<f>` - Navigates to Commit Files window
- File Diff:
  - `<b>` - Navigates to Branches List window
  - `<c>` - Navigates to Commit List window
  - `<f>` - Navigates to Commit Files window

## License

MIT License

Copyright (c) 2022 Ramon Moraes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
