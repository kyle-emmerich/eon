local client, server = nil, nil
local run_mode_obj = nil
if run_mode == 'client' then
	client = require 'client'
	run_mode_obj = client
elseif run_mode == 'server' then
	server = require 'server'
	run_mode_obj = server
end

love.run = run_mode_obj.run