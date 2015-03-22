/*
 * Copyright (C) 2014 Dominic Ward <contactdominicward@gmail.com>
 *
 * This file is part of Loudness
 *
 * Loudness is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Loudness is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Loudness.  If not, see <http://www.gnu.org/licenses/>. 
 */

%module loudness
%{
#define SWIG_FILE_WITH_INIT
#include "../src/cnpy/cnpy.h"
#include "../src/Support/Debug.h"
#include "../src/Support/UsefulFunctions.h"
#include "../src/Support/Common.h"
#include "../src/Support/SignalBank.h"
#include "../src/Support/Module.h"
#include "../src/Support/FFT.h"
#include "../src/Support/Filter.h"
#include "../src/Modules/FIR.h"
#include "../src/Modules/IIR.h"
#include "../src/Modules/Butter.h"
#include "../src/Modules/FrameGenerator.h"
#include "../src/Modules/Window.h"
#include "../src/Modules/PowerSpectrum.h"
%}

//Required for integration with numpy arrays
%include "numpy.i"
%init %{
    import_array();
%}

//apply all of the double typemaps to Real
%apply double { Real };
%apply unsigned int { uint };

%include "std_vector.i"
namespace std {
    //The argument to %template() is the name of the instantiation in the target language
    %template(RealVec) vector<double>;
    %template(IntVec) vector<int>;

    %apply vector<double>& { RealVec& };
    %apply const vector<double>& { const RealVec& };
    %apply vector<int> { IntVec };
    %apply vector<int>& { IntVec& };
    %apply const vector<int>& { const IntVec& };
}

%include "std_string.i"
using namespace std;

%apply (double* IN_ARRAY1, int DIM1) {(Real* data, int nSamples)}; 
%apply (double* IN_ARRAY3, int DIM1, int DIM2, int DIM3) {(Real* data, int nEars, int nChannels, int nSamples)};

namespace loudness{
using std::string;
using std::vector;

/*
Expose only a subset of SignalBank's public members
Extend the class with signal setters and getters for integration with Numpy
arrays.
*/
class SignalBank {

public:
    SignalBank();
    ~SignalBank();
    void initialize(int nEars, int nChannels, int nSamples, int fs);
    inline int getNChannels();
    inline int getNSamples();
    inline int getNEars();
    inline int getNTotalSamples();
    inline void setSample(int ear, int channel, int sample, Real value);
    inline Real getSample(int ear, int channel, int sample) const;
    inline bool getTrig();
    inline void setTrig(bool trig);
    %extend {

        PyObject* getSignal(int ear, int channel)
        {
            if (! loudness::isPositiveAndLessThanUpper(ear, $self -> getNEars()))
                ear = 0;
            if (! loudness::isPositiveAndLessThanUpper(channel, $self ->
                getNChannels()))
                channel = 0;
            const Real* ptr = $self -> getSignalReadPointer(ear, channel, 0);
            npy_intp dims[1] = {$self -> getNSamples()}; 
            return PyArray_SimpleNewFromData(1, dims, NPY_DOUBLE, (void*)ptr);
        }

        PyObject* getSignals()
        {
            const Real* ptr = $self -> getSignalReadPointer(0, 0, 0);
            npy_intp dims[3] = {$self -> getNEars(), $self -> getNChannels(), $self -> getNSamples()}; 
            return PyArray_SimpleNewFromData(3, dims, NPY_DOUBLE, (void*)ptr);
        }

        PyObject* getCentreFreqs()
        {
            const Real* ptr = $self -> getCentreFreqsReadPointer(0);
            npy_intp dims[1] = {$self -> getNChannels()}; 
            return PyArray_SimpleNewFromData(1, dims, NPY_DOUBLE, (void*)ptr);
        }

        void setSignal(int ear, int channel, Real* data, int nSamples)
        {
            if (! loudness::isPositiveAndLessThanUpper(ear, $self -> getNEars()))
                ear = 0;
            if (! loudness::isPositiveAndLessThanUpper(channel, $self ->
                getNChannels()))
                channel = 0;
            Real* ptr = $self -> getSignalWritePointer(ear, channel, 0);
            int nSamplesToCopy = loudness::min(nSamples, $self -> getNSamples());
            for (int i = 0; i < nSamplesToCopy; i++)
                ptr[i] = data[i];
        }

        void setSignals(Real* data, int nEars, int nChannels, int nSamples)
        {  
            Real* ptr = $self -> getSignalWritePointer(0, 0, 0);
            int nSamplesToCopy = loudness::min(nEars*nChannels*nSamples, $self -> getNTotalSamples());
            for (int i = 0; i < nSamplesToCopy; i++)
                ptr[i] = data[i];
        }

    }
};
}

%include "../src/cnpy/cnpy.h"
%include "../src/Support/Debug.h"
%include "../src/Support/UsefulFunctions.h"
%include "../src/Support/Common.h"
%include "../src/Support/SignalBank.h"
%include "../src/Support/Module.h"
%include "../src/Support/FFT.h"
%include "../src/Support/Filter.h"
%include "../src/Modules/FIR.h"
%include "../src/Modules/IIR.h"
%include "../src/Modules/Butter.h"
%include "../src/Modules/FrameGenerator.h"
%include "../src/Modules/Window.h"
%include "../src/Modules/PowerSpectrum.h"
