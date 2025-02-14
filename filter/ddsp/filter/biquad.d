/**
* Copyright 2017 Cut Through Recordings
* License: MIT License
* Author(s): Ethan Reker
*/
module ddsp.filter.biquad;

import ddsp.effect.effect;

const float pi = 3.14159265;

enum FilterType
{
    lowpass,
    highpass,
    bandpass,
    allpass,
    peak,
    lowshelf,
    highshelf,
}

/**
This class implements a generic biquad filter. Should be inherited by all filters.
*/
class BiQuad(T) : AudioEffect!T
{
    public:

        this() nothrow @nogc
        {

        }

        void initialize(T a0,
                        T a1,
                        T a2,
                        T b1,
                        T b2,
                        T c0 = 1,
                        T d0 = 0)  nothrow @nogc
        {
           _a0 = a0;
           _a1 = a1;
           _a2 = a2;
           _b1 = b1;
           _b2 = b2;
           _c0 = c0;
           _d0 = d0;
        }
        
        void setFrequency(float frequency) nothrow @nogc
        {
            if(_frequency != frequency)
            {
                _frequency = frequency;
                calcCoefficients();
            }
        }
    
        override void setSampleRate(float sampleRate) nothrow @nogc
        {
            _sampleRate = sampleRate;
            calcCoefficients();
            reset();
        }

        override T getNextSample(const T input)  nothrow @nogc
        {
            T output = (_a0 * input + _a1 * _xn1 + _a2 * _xn2 - _b1 * _yn1 - _b2 * _yn2) * _c0 + (input * _d0);

            _xn2 = _xn1;
            _xn1 = input;
            _yn2 = _yn1;
            _yn1 = output;

            return output;
        }

        override void reset()
        {
            _xn1 = 0;
            _xn2 = 0;
            _yn1 = 0;
            _yn2 = 0;
        }

        abstract void calcCoefficients() nothrow @nogc;

    protected:

        //Delay samples
        T _xn1=0, _xn2=0;
        T _yn1=0, _yn2=0;

        //Biquad Coeffecients
        T _a0=0, _a1=0, _a2=0;
        T _b1=0, _b2=0;
        T _c0=1, _d0=0;

        float _sampleRate;
        float _qFactor;
        float _frequency;
}