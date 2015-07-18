module.exports.remap = function(map, obj) {
	if (obj === null ||
		obj === undefined) {
		return;
	}
	for (var _old in map) {
		if (obj[_old] === undefined) continue;
		
		if (typeof map[_old] === 'string') {
			var _new = map[_old];
			obj[_new] = obj[_old];
			delete obj[_old];
		} else 

		if (typeof map[_old] === 'object') {
			var _nkey = Object.keys(map[_old])[0];
			var _nval = map[_old][_nkey](obj[_old]);
			obj[_nkey] = _nval;
			delete obj[_old];
		}
	}
};
