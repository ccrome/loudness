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

%module core
%{
#define SWIG_FILE_WITH_INIT
#include "../src/thirdParty/cnpy/cnpy.h"
#include "../src/thirdParty/spline/Spline.h"
#include "../src/support/Debug.h"
#include "../src/support/Common.h"
#include "../src/support/UsefulFunctions.h"
#include "../src/support/AuditoryTools.h"
#include "../src/support/SignalBank.h"
#include "../src/support/Module.h"
#include "../src/support/Model.h"
#include "../src/support/FFT.h"
#include "../src/support/Filter.h"
#include "../src/support/AudioFileProcessor.h"
#include "../src/modules/UnaryOperator.h"
#include "../src/modules/FIR.h"
#include "../src/modules/IIR.h"
#include "../src/modules/Butter.h"
#include "../src/modules/Biquad.h"
#include "../src/modules/SMA.h"
#include "../src/modules/EMA.h"
#include "../src/modules/AudioFileCutter.h"
#include "../src/modules/FrameGenerator.h"
#include "../src/modules/Window.h"
#include "../src/modules/PowerSpectrum.h"
#include "../src/modules/HoppingGoertzelDFT.h"
#include "../src/modules/WeightSpectrum.h"
#include "../src/modules/CompressSpectrum.h"
#include "../src/modules/RoexBankANSIS342007.h"
#include "../src/modules/FastRoexBank.h"
#include "../src/modules/MultiSourceRoexBank.h"
#include "../src/modules/DoubleRoexBank.h"
#include "../src/modules/MultiSourceDoubleRoexBank.h"
#include "../src/modules/FixedRoexBank.h"
#include "../src/modules/OctaveBank.h"
#include "../src/modules/SpecificLoudnessANSIS342007.h"
#include "../src/modules/SpecificPartialLoudnessMGB1997.h"
#include "../src/modules/SpecificPartialLoudnessCHGM2011.h"
#include "../src/modules/MainLoudnessDIN456311991.h"
#include "../src/modules/BinauralInhibitionMG2007.h"
#include "../src/modules/InstantaneousLoudness.h"
#include "../src/modules/ForwardMaskingPO1998.h"
#include "../src/modules/InstantaneousLoudnessDIN456311991.h"
#include "../src/modules/ARAverager.h"
#include "../src/modules/PeakFollower.h"
#include "../src/models/StationaryLoudnessANSIS342007.h"
#include "../src/models/StationaryLoudnessDIN456311991.h"
#include "../src/models/StationaryLoudnessCHGM2011.h"
#include "../src/models/DynamicLoudnessGM2002.h"
#include "../src/models/DynamicLoudnessCH2012.h"

typedef loudness::Real Real;
typedef loudness::uint unint;
typedef loudness::RealVec RealVec;
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
%include "std_string.i"
namespace std {
    //The argument to %template() is the name of the instantiation in the target language
    %template(RealVec) vector<double>;
    %template(IntVec) vector<int>;
    %template(StringVec) vector<string>;

    %apply vector<double>& { RealVec& };
    %apply const vector<double>& { const RealVec& };
    %apply vector<int> { IntVec };
    %apply vector<int>& { IntVec& };
    %apply const vector<int>& { const IntVec& };
    %apply vector<string>& { StringVec };
}

%apply (double* IN_ARRAY1, int DIM1) {(Real* data, int nSamples)};
%apply (double* IN_ARRAY1, int DIM1) {(Real* data, int nChannels)};
%apply (double* IN_ARRAY4, int DIM1, int DIM2, int DIM3, int DIM4) {
    (Real* data, int nSources, int nEars, int nChannels, int nSamples)};

using namespace std;
namespace loudness{
using std::string;
using std::vector;
}

%include "./SignalBank.i"
%include "../src/thirdParty/cnpy/cnpy.h"
%include "../src/thirdParty/spline/Spline.h"
%include "../src/support/Debug.h"
%include "../src/support/Common.h"
%include "../src/support/UsefulFunctions.h"
%include "../src/support/AuditoryTools.h"
%include "../src/support/Module.h"
%include "../src/support/Model.h"
%include "../src/support/FFT.h"
%include "../src/support/Filter.h"
%include "../src/support/AudioFileProcessor.h"
%include "../src/modules/UnaryOperator.h"
%include "../src/modules/FIR.h"
%include "../src/modules/IIR.h"
%include "../src/modules/Butter.h"
%include "../src/modules/Biquad.h"
%include "../src/modules/SMA.h"
%include "../src/modules/EMA.h"
%include "../src/modules/AudioFileCutter.h"
%include "../src/modules/FrameGenerator.h"
%include "../src/modules/Window.h"
%include "../src/modules/PowerSpectrum.h"
%include "../src/modules/HoppingGoertzelDFT.h"
%include "../src/modules/WeightSpectrum.h"
%include "../src/modules/CompressSpectrum.h"
%include "../src/modules/RoexBankANSIS342007.h"
%include "../src/modules/FastRoexBank.h"
%include "../src/modules/MultiSourceRoexBank.h"
%include "../src/modules/FixedRoexBank.h"
%include "../src/modules/DoubleRoexBank.h"
%include "../src/modules/MultiSourceDoubleRoexBank.h"
%include "../src/modules/OctaveBank.h"
%include "../src/modules/SpecificLoudnessANSIS342007.h"
%include "../src/modules/SpecificPartialLoudnessMGB1997.h"
%include "../src/modules/SpecificPartialLoudnessCHGM2011.h"
%include "../src/modules/MainLoudnessDIN456311991.h"
%include "../src/modules/BinauralInhibitionMG2007.h"
%include "../src/modules/InstantaneousLoudness.h"
%include "../src/modules/ForwardMaskingPO1998.h"
%include "../src/modules/InstantaneousLoudnessDIN456311991.h"
%include "../src/modules/ARAverager.h"
%include "../src/modules/PeakFollower.h"
%include "../src/models/StationaryLoudnessANSIS342007.h"
%include "../src/models/StationaryLoudnessDIN456311991.h"
%include "../src/models/StationaryLoudnessCHGM2011.h"
%include "../src/models/DynamicLoudnessGM2002.h"
%include "../src/models/DynamicLoudnessCH2012.h"
