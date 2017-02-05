var yuki540 = function() {
	function yuki540() {
		
	}

	/**
	 * 要素の取得
	 * @param selector: セレクタ名
	 * @return          要素
	 */
	yuki540.prototype.$ = function(selector) {
		let ele = querySelectorAll(selector);

		if(ele.length === 1)
			return ele[0];
		else 
			return ele;
	};

	/**
	 * XMLHttpRequest
	 * @param params:   通信のパラメータ
	 * @param callback: コールバック関数
	 */
	yuki540.prototype.ajax = function(params, callback) {
		let req = new XMLHttpRequest();
		req.open(params.method, params.url);
		req.onreadystatechange = function() {
			if(req.readyState === 4) 
				callback(req);
		};

		if(params.body === undefined)
			params.body = null; 
		req.send(params.body);
	};

	/**
	 * xss対策
	 * @param text: 文字列
	 * @return      エスケープ済の文字列
	 */
	yuki540.prototype.escape = function(text) {
		text = text.replace(/</g, '&gt;');
		text = text.replace(/>/g, '&lt;');
		text = text.replace(/&/g, '&amp;');
		text = text.replace(/\"/g, '&quot;');
		text = text.replace(/\"/g, '');

		return text;
	};

	/**
	 * オブジェクトのコピーを作成
	 * @param obj: 対象オブジェクト
	 * @return     コピーしたオブジェクト
	 */
	yuki540.prototype.copy = function(obj) {
		return JSON.parse(JSON.stringify(obj));
	};

	/**
	 * ２点間の間かチェック
	 * @param a: 点1
	 * @param b: 点2
	 * @param v: 値
	 * @return   真偽値
	 */
	yuki540.prototype.between = function(a, b, v) {
		if(a <= v && b >= v)
			return true;
		else 
			return false; 
	};

	/**
	 * 配列の中身を全て特定の値に書き換える
	 * @param list: 対象配列
	 * @param a:    書き換える値
	 * @return      書き換え終了配列
	 */
	yuki540.prototype.fill = function(list, a) {
		for(let i=0; i < list.length; i++) 
			list[i] = a;

		return list;
	};

	/**
	 * 割合を取得
	 * @param p1: 最小値
	 * @param p2: 最大値
	 * @param v:  値
	 * @return    割合
	 */
	yuki540.prototype.per = function(p1, p2, v) {
		// 正当な数値に変換
		p2 -= p1;
		v  -= p1;

		return v / p2;
	};

	/**
	 * 割合を掛け合わせる
	 * @param p1:  最小値
	 * @param p2:  最大値
	 * @param per: 割合
	 * @return     掛け合わせた値
	 */
	yuki540.prototype.rate = function(p1, p2, per) {
		let diff = this.diff(p2, p1) * per;
		return p1 + diff;
	};

	/**
	 * リストの中から近いものを返す
	 * @param a:    比較対象
	 * @param list: 比較リスト
	 * @return      最も近い値
	 */
	yuki540.prototype.near = function(a, list) {
		let num   = 0
		,  	diff1 = Math.abs(this.diff(a, list[0]));
		
		for(let i=1;  i < list.length; i++) {
			let diff2 = Math.abs(this.diff(a, list[i]));
			if(diff1 > diff2) {
				num   = i;
				diff1 = diff2;
			}
		}

		return list[num];
	};

	/**
	 * 2点の差分を取得
	 * @param a: 比較対象1
	 * @param b: 比較対象2
	 * @return   差分
	 */
	yuki540.prototype.diff = function(a, b) {
		if(a > b)
			return a - b;
		else 
			return -(b - a);
	};

	return new yuki540();
}();