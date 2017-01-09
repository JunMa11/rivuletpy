<!--
 Copyright (c) 2016, RivuletStudio, The University of Sydney, AU
 All rights reserved.

 This file is part of Rivuletpy <https://github.com/RivuletStudio/rivuletpy>

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
     3. Neither the name of the copyright holder nor the names of
        its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 -->

# Rivuletpy

Rivuletpy is a Python3 toolkit for automatically reconstructing single neuron models from 3D microscopic image stacks.

The `rtrace` command is powered by the latest neuron tracing algorithm Rivulet2.

A C++ implementation of the Rivulet2 algorithm is also available in the lastest [Vaa3D](https://github.com/Vaa3D) under the Rivulet Plugin.

## Installation
### 0. Setup the virtualenv
It is recommended that you use [`pip`](https://pip.pypa.io/en/stable/) to install
`Rivuletpy` into a [`virtualenv`](https://virtualenv.pypa.io/en/stable/). The following
assumes a `virtualenv` named `riv` has been set up and
activated. We will see three ways to install `Rivuletpy`
```
$ virtualenv -p python3 riv
$ . riv/bin/activate
```

### 1. Setup the dependencies
To install rivuletpy, you need to install the following packages beforehand:

* `numpy>=1.8.0`
* `scipy>=0.17.0`
* `Cython>=0.25.1`

### 2A. Install Rivuletpy from the Pypi (Recommended)

```
(riv)$ pip3 install rivuletpy
```


### 2B. Install Rivuletpy from the git repo (Optional)

```
(riv)$ pip3 install git+https://github.com/RivuletStudio/rivuletpy
```

### 2C. Install Rivuletpy from source (Optional)
Optionally you can install Rivuletpy from the source files

```
(riv)$ git clone https://github.com/RivuletStudio/rivuletpy.git
(riv)$ cd rivuletpy
(riv)$ pip3 install -e .
```

This installs `Rivuletpy` into your `virtualenv` in "editable" mode. That means changes
made to the source code are seen by the installation. To install in read-only mode, omit
the `-e`.

## Test Installation
In ./rivuletpy/
`sh quicktest.sh`

This will download a simple neuron image and perform a neuron tracing with rivulet2 algorithm.

## Usage
- Reconstruct single neuron file.

The script rtrace command will be installed
```bash
$ rtrace --help
usage: rivulet2 [-h] -f FILE [-o OUT] [-t THRESHOLD] [-z ZOOM_FACTOR]
                [--save-soma] [--no-save-soma] [--soma] [--no-soma]
                [--speed SPEED] [--quality] [--no-quality] [--clean]
                [--no-clean] [--silent] [--no-silent]

Arguments to perform the Rivulet2 tracing algorithm.

optional arguments:
  -h, --help            show this help message and exit
  -f FILE, --file FILE  The input file. A image file (*.tif, *.nii, *.mat).
  -o OUT, --out OUT     The name of the output file
  -t THRESHOLD, --threshold THRESHOLD
                        threshold to distinguish the foreground and
                        background. Defulat 0. If threshold<0, otsu will be
                        used.
  -z ZOOM_FACTOR, --zoom_factor ZOOM_FACTOR
                        The factor to zoom the image to speed up the whole
                        thing. Default 1.
  --save-soma
  --no-save-soma
  --soma
  --no-soma
  --speed SPEED         The type of speed image to use (dt, ssm)
  --quality
  --no-quality
  --clean
  --no-clean
  --silent
  --no-silent

$ rtrace -f example.tif -t 10 # Simple like this
$ rtrace -f example.tif -t 10 --quality # Better results with longer running time
```

Please note that Rivulet2 is powerful of handling the noises, a relatively low intensity threshold is preferred to include all the candidate voxels.

- Compare a swc reconstruction against the manual ground truth
```
$ compareswc --help
usage: compareswc [-h] --target TARGET --groundtruth GROUNDTRUTH
                  [--sigma SIGMA]

Arguments for comparing two swc files.

optional arguments:
  -h, --help            show this help message and exit
  --target TARGET       The input target swc file.
  --groundtruth GROUNDTRUTH
                        The input ground truth swc file.
  --sigma SIGMA         The sigma value to use for the Gaussian function in
                        NetMets.

$ compareswc --target r2_tracing.swc --groundtruth hand_tracing.swc
0.9970 0.8946 0.9865 1 3
```
The `compareswc` command outputs five numbers which are in order: 

precision, recall, f1-score, No. connection error type A, No. connection error type B

## Dependencies

The build-time and runtime dependencies of Rivuletpy are:

* [numpy](http://www.numpy.org/)
* [scipy](http://www.scipy.org/)
* [Cython](http://cython.org/)
* [scikit-fmm](https://github.com/scikit-fmm)
* [scikit-image](https://github.com/scikit-image)
* [matplotlib](http://www.matplotlib.org/)
* [tqdm](https://github.com/noamraph/tqdm)
* [nibabel](http://nipy.org/nibabel/)

## Reporting issues

Issues should be reported to the
[Rivuletpy github repository issue tracker](https://github.com/RivuletStudio/rivuletpy/issues).
The ability and speed with which issues can be resolved depends on how complete and
succinct the report is. For this reason, it is recommended that reports be accompanied
with a minimal but self-contained code sample that reproduces the issue, the observed and
expected output, and if possible, the commit ID of the version used. If reporting a
regression, the commit ID of the change that introduced the problem is also extremely valuable
information.

Questions are also welcomed in the [Rivuletpy github repository issue tracker](https://github.com/RivuletStudio/rivuletpy/issues).
If you put on a `question` label
