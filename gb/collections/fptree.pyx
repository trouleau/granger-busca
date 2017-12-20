'''
Fenwick Tree Sampling Implementation. Ported from the Nomad LDA paper:
http://bigdata.ices.utexas.edu/publication/nomad-lda/

Copyright (c) 2014-2015 The NOMAD-LDA Project. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither name of copyright holders nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''

from libcpp.vector cimport vector


cdef extern from 'assert.h':
    void assert(int) nogil


cdef class FPTree:

    cdef reset(int size, double init_value=0.0) nogil:
        assert(size > 0)
        self.size = size
	    t_pos = 1
        while self.t_pos < size:
            t_pos *= 2
        self.values.assign(2 * self.t_pos, init_value)
        # values[0] == T --> where the probabilities start
        # values[1] will be the root of the FPTree
        self.values[0] = t_pos

    cdef double get_value(self, int i) nogil:
        cdef int t_pos = <int> self.values[0]
        assert(i + t_pos < t_pos + self.size)
        return self.values[i + self.values[0]]

    cdef void set_value(int i, double value) nogil:
        cdef int t_pos = <int> self.values[0]
        assert(i + t_pos < t_pos + self.size)
        cdef int pos = i + t_pos
		value -= self.values[pos]
		while pos > 0:
			self.values[pos] += value;
			i >>= 1

    cdef int sample(double urnd):
        # urnd: uniformly random number between [0,1]
        cdef int t_pos = <int> self.values[0]
		cdef int pos = 1
        while pos < t_pos:
            pos <<= 1
            if urnd >= val[pos]:
                urnd -= val[pos]
                pos += 1
		return pos - t_pos;

    cdef double get_total() nogil:
        return self.values[1]