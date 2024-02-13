#!/bin/bash

tee > /tmp/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF
source scl_source enable gcc-toolset-12
mv /tmp/oneAPI.repo /etc/yum.repos.d
#dnf install intel-oneapi-mkl -y
dnf install xsimd-devel intel-oneapi-mkl-devel.x86_64 -y 
source scl_source enable gcc-toolset-12
. /opt/intel/oneapi/setvars.sh
cd /tmp
python -m pip install --upgrade pip

pip install virtualenv
BUILD_NUMPY_ENV_ROOT=build_numpy
python -m venv  ${BUILD_NUMPY_ENV_ROOT}
. ./${BUILD_NUMPY_ENV_ROOT}/bin/activate
pip install --upgrade pip
mkdir /tmp/numpy
cd /tmp/numpy
NP_VERSION=1.26.4
git clone https://github.com/numpy/numpy.git
cd numpy
git checkout v${NP_VERSION}
git submodule update --init
pip install -r build_requirements.txt
python -m build -Csetup-args=-Dblas=mkl-sdl -Csetup-args=-Dlapack=mkl-sdl -Csetup-args=-Dmkl-threading=tbb

SCIPY_VERSION=1.12.0
cd /tmp
BUILD_SCIPY_ENV_ROOT=build_scipy
python -m venv  ${BUILD_SCIPY_ENV_ROOT}
. ./${BUILD_SCIPY_ENV_ROOT}/bin/activate
python -m pip install --upgrade pip
# Build dependencies
python -m pip install ./numpy/numpy/dist/numpy-${NP_VERSION}-cp311-cp311-linux_x86_64.whl
python -m pip install build cython pythran pybind11 meson ninja pydevtool rich-click

# Test and optional runtime dependencies
python -m pip install pytest pytest-xdist pytest-timeout pooch threadpoolctl asv gmpy2 mpmath

# Doc build dependencies
python -m pip install sphinx "pydata-sphinx-theme==0.9.0" sphinx-design matplotlib numpydoc jupytext myst-nb

mkdir /tmp/scipy
cd /tmp/scipy
git clone https://github.com/scipy/scipy.git
cd scipy
git checkout v${SCIPY_VERSION}
git submodule update --init

python -m build -Csetup-args=-Dblas=mkl-sdl -Csetup-args=-Dlapack=mkl-sdl
