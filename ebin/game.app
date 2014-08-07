{application, game, [
	{description, ""},
	{vsn, "0.1.0"},
	{modules, ['game_sup', 'game_app', 'game']},
	{registered, []},
	{applications, [
		kernel,
		stdlib
	]},
	{mod, {game_app, []}},
	{env, []}
]}.
