sidebarNodes={"extras":[{"id":"api-reference","title":"API Reference","group":"","headers":[{"id":"Modules","anchor":"modules"}]},{"id":"readme","title":"README","group":"","headers":[{"id":"Overview","anchor":"overview"},{"id":"Usage","anchor":"usage"},{"id":"Contributing","anchor":"contributing"},{"id":"Inspiration","anchor":"inspiration"},{"id":"License","anchor":"license"}]},{"id":"cheatsheet","title":"Cheatsheet","group":"","headers":[{"id":"Commands","anchor":"commands"},{"id":"Build States","anchor":"build-states"}]},{"id":"contributing","title":"Contributing","group":"","headers":[{"id":"Where to Start","anchor":"where-to-start"},{"id":"Development","anchor":"development"},{"id":"Reporting Issues","anchor":"reporting-issues"},{"id":"Conventions","anchor":"conventions"}]}],"exceptions":[],"modules":[{"id":"Gullintanni","title":"Gullintanni","functions":[{"id":"start/2","anchor":"start/2"}]},{"id":"Gullintanni.Comment","title":"Gullintanni.Comment","functions":[{"id":"new/4","anchor":"new/4"}],"types":[{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.Config","title":"Gullintanni.Config","functions":[{"id":"load/1","anchor":"load/1"},{"id":"load/2","anchor":"load/2"},{"id":"parse_runtime_settings/1","anchor":"parse_runtime_settings/1"},{"id":"settings_present?/2","anchor":"settings_present?/2"}],"types":[{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.MergeRequest","title":"Gullintanni.MergeRequest","functions":[{"id":"approve/3","anchor":"approve/3"},{"id":"approved_at/1","anchor":"approved_at/1"},{"id":"build_error/1","anchor":"build_error/1"},{"id":"build_failed/1","anchor":"build_failed/1"},{"id":"build_passed/1","anchor":"build_passed/1"},{"id":"ffwd_failed/1","anchor":"ffwd_failed/1"},{"id":"merge_failed/1","anchor":"merge_failed/1"},{"id":"merge_passed/1","anchor":"merge_passed/1"},{"id":"new/2","anchor":"new/2"},{"id":"reset/1","anchor":"reset/1"},{"id":"unapprove/2","anchor":"unapprove/2"},{"id":"update_sha/2","anchor":"update_sha/2"}],"types":[{"id":"id/0","anchor":"t:id/0"},{"id":"sha/0","anchor":"t:sha/0"},{"id":"state/0","anchor":"t:state/0"},{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.Pipeline","title":"Gullintanni.Pipeline","functions":[{"id":"authorized?/2","anchor":"authorized?/2"},{"id":"get/1","anchor":"get/1"},{"id":"get/2","anchor":"get/2"},{"id":"handle_comment/2","anchor":"handle_comment/2"},{"id":"handle_mreq_close/2","anchor":"handle_mreq_close/2"},{"id":"handle_mreq_open/2","anchor":"handle_mreq_open/2"},{"id":"handle_push/3","anchor":"handle_push/3"},{"id":"put/3","anchor":"put/3"},{"id":"start_link/1","anchor":"start_link/1"},{"id":"valid_config?/1","anchor":"valid_config?/1"},{"id":"whereis/1","anchor":"whereis/1"}],"types":[{"id":"name/0","anchor":"t:name/0"},{"id":"pipeline/0","anchor":"t:pipeline/0"},{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.Pipeline.Supervisor","title":"Gullintanni.Pipeline.Supervisor","functions":[{"id":"init/1","anchor":"init/1"},{"id":"start_link/0","anchor":"start_link/0"},{"id":"start_pipeline/1","anchor":"start_pipeline/1"}]},{"id":"Gullintanni.Provider","title":"Gullintanni.Provider","callbacks":[{"id":"__domain__/0","anchor":"c:__domain__/0"},{"id":"download_merge_requests/2","anchor":"c:download_merge_requests/2"},{"id":"parse_merge_request/1","anchor":"c:parse_merge_request/1"},{"id":"valid_config?/1","anchor":"c:valid_config?/1"},{"id":"whoami/1","anchor":"c:whoami/1"}],"types":[{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.Providers.GitHub","title":"Gullintanni.Providers.GitHub","functions":[{"id":"download_merge_requests/2","anchor":"download_merge_requests/2"},{"id":"parse_comment/1","anchor":"parse_comment/1"},{"id":"parse_merge_request/1","anchor":"parse_merge_request/1"},{"id":"parse_repo/1","anchor":"parse_repo/1"},{"id":"post_comment/4","anchor":"post_comment/4"},{"id":"valid_config?/1","anchor":"valid_config?/1"},{"id":"whoami/1","anchor":"whoami/1"}]},{"id":"Gullintanni.Providers.GitHub.EventHandler","title":"Gullintanni.Providers.GitHub.EventHandler","functions":[{"id":"handle_events/3","anchor":"handle_events/3"},{"id":"init/1","anchor":"init/1"},{"id":"start_link/0","anchor":"start_link/0"}]},{"id":"Gullintanni.Repo","title":"Gullintanni.Repo","functions":[{"id":"new/3","anchor":"new/3"}],"types":[{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.Webhook.Event","title":"Gullintanni.Webhook.Event","functions":[{"id":"get_payload/1","anchor":"get_payload/1"},{"id":"get_req_header/2","anchor":"get_req_header/2"}],"types":[{"id":"payload/0","anchor":"t:payload/0"},{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.Webhook.EventManager","title":"Gullintanni.Webhook.EventManager","functions":[{"id":"handle_demand/2","anchor":"handle_demand/2"},{"id":"init/1","anchor":"init/1"},{"id":"start_link/0","anchor":"start_link/0"},{"id":"sync_notify/2","anchor":"sync_notify/2"}]},{"id":"Gullintanni.Webhook.Router","title":"Gullintanni.Webhook.Router","functions":[{"id":"call/2","anchor":"call/2"},{"id":"init/1","anchor":"init/1"}]},{"id":"Gullintanni.Webhook.Supervisor","title":"Gullintanni.Webhook.Supervisor","functions":[{"id":"init/1","anchor":"init/1"},{"id":"start_link/0","anchor":"start_link/0"}]},{"id":"Gullintanni.Worker","title":"Gullintanni.Worker","callbacks":[{"id":"valid_config?/1","anchor":"c:valid_config?/1"}],"types":[{"id":"config/0","anchor":"t:config/0"},{"id":"t/0","anchor":"t:t/0"}]},{"id":"Gullintanni.Workers.TravisCI","title":"Gullintanni.Workers.TravisCI","functions":[{"id":"valid_config?/1","anchor":"valid_config?/1"}]},{"id":"GullintanniWeb","title":"GullintanniWeb","functions":[{"id":"start/2","anchor":"start/2"}]},{"id":"GullintanniWeb.Router","title":"GullintanniWeb.Router","functions":[{"id":"call/2","anchor":"call/2"},{"id":"init/1","anchor":"init/1"}]},{"id":"HardHat","title":"HardHat","functions":[{"id":"get/2","anchor":"get/2"},{"id":"post/3","anchor":"post/3"},{"id":"put/3","anchor":"put/3"}],"types":[{"id":"response/0","anchor":"t:response/0"},{"id":"status_code/0","anchor":"t:status_code/0"}]},{"id":"HardHat.Client","title":"HardHat.Client","functions":[{"id":"new/2","anchor":"new/2"}],"types":[{"id":"auth/0","anchor":"t:auth/0"},{"id":"endpoint/0","anchor":"t:endpoint/0"},{"id":"t/0","anchor":"t:t/0"}]},{"id":"HardHat.Users","title":"HardHat.Users","functions":[{"id":"show/2","anchor":"show/2"},{"id":"sync/1","anchor":"sync/1"},{"id":"whoami/1","anchor":"whoami/1"}]},{"id":"Socket","title":"Socket","functions":[{"id":"new/2","anchor":"new/2"}],"types":[{"id":"ip_address/0","anchor":"t:ip_address/0"},{"id":"port_number/0","anchor":"t:port_number/0"},{"id":"t/0","anchor":"t:t/0"}]}],"protocols":[]}