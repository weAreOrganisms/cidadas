/*
m.utils.setFFtRangeFor(Ndef('fft-0'), \c200, \cPattern)
*/

m.utils.setFFtRangeFor = {|q, ndef, bName, rangeName|
	var range = m.config.freqRanges[bName][rangeName].asSpec;
	var last_lFreq, last_hFreq;

	last_lFreq = ndef.getUni(\lowcutFreq);
	last_hFreq = ndef.getUni(\highcutFreq);

	ndef.addSpec(
		\lowcutFreq, range,
		\highcutFreq, range,
	);
	// TODO: fadeTime?
	ndef.map(\in, m.helpers[bName]);

	ndef.xset(
	// \in, m.helpers[bName].bus.index,
		\lowcutFreq, range.map(last_lFreq),
		\highcutFreq, range.map(last_hFreq)
	)
}
