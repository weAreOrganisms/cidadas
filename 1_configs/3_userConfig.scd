// user configs like your artist name, specific hardware-related parameters etc. go here.

m.config.name = m.config.name ?? {\LFSawDE};
m.config.maxFrame = 2**24; // maximum number of frames to be read from soundfiles
m.config.loopDeltas = ([1/8, 1/4, 1/2, 1, 2, 4, 8, 16, 32, 64] ++  [1/12,1/3]).sort;

m.config.windowSize = 8192;
m.config.fftSize = m.config.windowSize;

m.config.sampleNames = [
	// 'c187_1',
	// 'c187_2',
	// 'c188',
	// 'c195_1',
	// 'c195_2',
	// 'c196', // no freqs in freqRanges
	'c198',
	'c200',
	'c204',
	'c206'
];



m.config.freqRanges = m.config.freqRanges.select{|range, key|
	m.config.sampleNames.includes(key.postln)
};


nil; // return value
