m.utils.fftWindow = Window("fft", Rect(0, 0, 1200, 400), scroll: true).decorate.front;
m.utils.patternWindow = Window("patterns", Rect(0, 0, 1200, 400), scroll: true).decorate.front;

m.utils.makeFFTControl = {|q, window, ndef|
	StaticText(window, 50@20).string_(ndef.key.asString);
	// Button(window, 20@20).states_([
	// 	["x", Color.black, Color.red],
	// 	[" ", Color.black, Color.gray],
	// ]).action_{|me|
	// 	(me.value > 0).if({
	// 		ndef.set(\on, 1)
	// 		}, {
	// 			ndef.set(\on, 0)
	// 	});
	// };
	// from
	RangeSlider(window, 250@20).action_{|me|
		ndef.setUni(\lowcutFreq, me.lo, \highcutFreq, me.hi);
	}.lo_(ndef.getUni(\lowcutFreq)).hi_(ndef.getUni(\highcutFreq));
	// to
	RangeSlider(window, 250@20).action_{|me|
		ndef.setUni(\tlFreq, me.lo, \thFreq, me.hi)}.lo_(ndef.getUni(\tlFreq)).hi_(ndef.getUni(\thFreq));
	// volume
	// EZSlider(window, 200@20, action: {|me| ndef.vol = me.value});
	EZSlider(window, 300@20, "amp", ndef.getSpec(\postAmp), action: {|me| ndef.set(\postAmp, me.value)}, initVal: ndef.get(\postAmp));
	// select input
	PopUpMenu(window, 200@20).items_(
		m.config.freqRanges.collect({|subDict, key|
			subDict.keys.as(Array).collect{|subKey|
				"% %".format(key, subKey)
			}
		}).as(Array).flatten.sort
	).action_{|me|
		var keys = me.item.split($ ).collect(_.asSymbol);
		m.utils.setFFtRangeFor(ndef, keys[0], keys[1])
	};
	// fadeTime
	EZSlider(window, 100@20, controlSpec: [0, 10].asSpec, label: "fadeTime", action: {|me| ndef.fadeTime = me.value}, initVal: ndef.fadeTime);
	window.view.decorator.nextLine;
};

m.utils.makePlayerControlNoRate = {|q, window, ndef|
	// StaticText(window, 200@20).string_(ndef.key.asString);
	var deltaButtons;

	Button(window, 50@20).states_([
		[ndef.key.asString, Color.black, Color.gray],
		[ndef.key.asString, Color.black, Color.red],
	]).action_{|me|
		ndef.set(\trigger, 1)
	};
	// rate
	// EZSlider(window, 200@20, action: {|me| ndef.setUni(\rate, me.value)});
	// delta
	// EZSlider(window, 200@20, label: "delta", action: {|me| ndef.setUni(\delta, me.value)});
	deltaButtons = m.config.loopDeltas.collect{|delta|
		Button(window, 30@20).states_([
			[delta.asString, Color.black, Color.gray],
			[delta.asString, Color.black, Color.green],
		])
	};
	deltaButtons.do{|b, i| b.action_{|me|
		deltaButtons.do{|others|
			others.value = 0;
		};
		me.value = 1;
		ndef.set(\delta, m.config.loopDeltas[i])
	}};
	window.view.decorator.nextLine;
};

m.utils.makePatternExtr = {|q, window, ndef|
	// StaticText(window, 200@20).string_(ndef.key.asString);
	var deltaButtons;

	Button(window, 50@20).states_([
		[ndef.key.asString, Color.black, Color.gray],
		[ndef.key.asString, Color.black, Color.red],
	]).action_{|me|
		ndef.set(\trigger, 1)
	};
	// delta
	// EZSlider(window, 200@20, label: "delta", action: {|me| ndef.setUni(\delta, me.value)});
	deltaButtons = m.config.loopDeltas.collect{|delta|
		Button(window, 30@20).states_([
			[delta.asString, Color.black, Color.gray],
			[delta.asString, Color.black, Color.green],
		])
	};
	window.view.decorator.nextLine;

	deltaButtons.do{|b, i| b.action_{|me|
		deltaButtons.do{|others|
			others.value = 0;
		};
		me.value = 1;
		ndef.set(\delta, m.config.loopDeltas[i])
	}};
	EZSlider(window, 300@20, "rate", ndef.getSpec(\rate), action: {|me| ndef.set(\rate, me.value)}, initVal: ndef.get(\rate));
	EZSlider(window, 300@20, "amp synt", ndef.getSpec(\synthAmp), action: {|me| ndef.set(\synthAmp, me.value)}, initVal: ndef.get(\synthAmp));
	EZSlider(window, 300@20, "amp noiz", ndef.getSpec(\noiseAmp), action: {|me| ndef.set(\noiseAmp, me.value)}, initVal: ndef.get(\noiseAmp));
	window.view.decorator.nextLine;
	EZSlider(window, 300@20, "contr", ndef.getSpec(\ampContrast), action: {|me| ndef.set(\ampContrast, me.value)}, initVal: ndef.get(\ampContrast));
	EZSlider(window, 300@20, "fre synt", ndef.getSpec(\rootFreq), action: {|me| ndef.set(\rootFreq, me.value)}, initVal: ndef.get(\rootFreq));
	EZSlider(window, 300@20, "amp ban", ndef.getSpec(\bandAmp), action: {|me| ndef.set(\bandAmp, me.value)});
	window.view.decorator.nextLine;
	EZSlider(window, 300@20, "anFreq", ndef.getSpec(\analysisFreq), action: {|me| ndef.set(\analysisFreq, me.value)}, initVal: ndef.get(\analysisFreq));
	EZSlider(window, 300@20, "fb", ndef.getSpec(\fbScale), action: {|me| ndef.set(\fbScale, me.value)}, initVal: ndef.get(\fbScale));
	EZSlider(window, 300@20, "amp", ndef.getSpec(\postAmp), action: {|me| ndef.set(\postAmp, me.value)}, initVal: ndef.get(\postAmp));

	window.view.decorator.nextLine;
};










/////////// fft

// player
m.helpers.select{|ndef| ndef.key.asString.contains("c")}.as(Array).sort({|a, b| a.key.asString < b.key.asString}).do{|ndef|
	m.utils.makePlayerControlNoRate(m.utils.fftWindow, ndef);
};

// fft
m.gens.select{|ndef| ndef.key.asString.contains("fft")}.as(Array).sort({|a, b| a.key.asString < b.key.asString}).do{|ndef|
	m.utils.makeFFTControl(m.utils.fftWindow, ndef);
};

/////////// pattern

m.gens.select{|ndef| ndef.key.asString.contains("p")}.as(Array).sort({|a, b| a.key.asString < b.key.asString}).do{|ndef|
	m.utils.makePatternExtr(m.utils.patternWindow, ndef);
};

