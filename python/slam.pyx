# distutils: language = c++

from libcpp.string cimport string
from libcpp cimport bool

from cython.operator cimport dereference as deref
from cpython.ref cimport PyObject

import numpy as np

cdef extern from "opencv2/core/core.hpp" namespace "cv":

  cdef int CV_8UC1

  cdef cppclass Mat:
    # Without this declaration the C++ exceptions raised by the constructor
    # will *not* be properly handled by Cython
    Mat() except +
    int *data
    int rows;
    int cols;
    void release() const
    void create(int, int, int)

# Re-use the official wrapper conversion functions + NumPy's import_array()
# function
cdef extern from "cv2.cpp":
  void import_array()
  PyObject* pyopencv_from(const Mat&)
  bool pyopencv_to(PyObject*, Mat&)

cdef extern from "System.h" namespace "ORB_SLAM2":

  cdef cppclass System:

    enum eSensor:
      MONOCULAR = 0
      STEREO = 1
      RGBD = 2

    System(string strVocFile, string strSettingsFile, eSensor sensor, bool bUseViewer)
    Mat TrackMonocular(Mat im, double timestamp)
    void Reset()
    bool isCurFrameAKeyFrame()
    void Shutdown()
    void SaveKeyFrameTrajectoryTUM(string filename)
    Mat GetGoodMapPoints()


cdef class VOSystem:

  cdef System *_thisptr

  def __cinit__(self, string strVocFile, string strSettingsFile, System.eSensor sensor, bool bUseViewer):
    self._thisptr = new System(strVocFile, strSettingsFile, sensor, bUseViewer)

  def __dealloc__(self):
    if self._thisptr != NULL:
      del self._thisptr

  cpdef void init_numpy_integration(self):
    import_array()

  cpdef object TrackMonocular(self, object in_array, double timestamp):
    cdef Mat in_mat
    cdef PyObject* pyobject = <PyObject*> in_array

    if not pyopencv_to(pyobject, in_mat):
      print 'Problems converting NumPy array to OpenCV mat :()'
      return in_array # FIX: Throw exception

    out_mat = self._thisptr.TrackMonocular(in_mat, timestamp)
    return <object> pyopencv_from(out_mat)

  cpdef void Reset(self):
    self._thisptr.Reset()

  cpdef bool isCurFrameAKeyFrame(self):
    return self._thisptr.isCurFrameAKeyFrame()

  cpdef void Shutdown(self):
    """ All threads will be requested to finish. It waits until all threads have
    finished. This function must be called before saving the trajectory."""
    self._thisptr.Shutdown()

  cpdef void SaveKeyFrameTrajectoryTUM(self, string filename):
    self._thisptr.SaveKeyFrameTrajectoryTUM(filename)

  cpdef object GetGoodMapPoints(self):
    out_mat = self._thisptr.GetGoodMapPoints()
    return <object> pyopencv_from(out_mat)
