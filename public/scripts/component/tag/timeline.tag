timeline

	style(scoped).
		:scope {
			position: absolute;
			bottom: -70px;
			left: 0;
			display: block;
			width: 100%;
			height: 70px;
			background-color: #333;
			animation: show-timeline 0.5s ease 0s forwards;
		}
		@keyframes show-timeline {
			0%   { bottom: -70px; }
			100% { bottom: 0px; }
		}

	script(type="coffee").

