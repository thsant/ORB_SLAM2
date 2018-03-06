from distutils.core import setup, Extension
from Cython.Build import cythonize
import os

ext = Extension("slam",
sources=["slam.pyx",
         "../src/System.cc",
         "cv2.cpp"],
include_dirs = ["../include",
                "../",
                "/usr/include/eigen3",
                "/usr/local/include/opencv",
                "/usr/local/include",
		"/usr/lib/python2.7/dist-packages/numpy/core/include"],
libraries=['stdc++',
           'DBoW2',
           'ORB_SLAM2',
           'opencv_core'],
library_dirs=["../Thirdparty/DBoW2/lib",
              '../lib'],
language="c++",
extra_compile_args=['-g', '-std=c++11'],
extra_link_args=["-std=c++11"])

setup(name="slam", ext_modules=cythonize(ext))
