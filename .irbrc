#Load the readline module.
IRB.conf[:USE_READLINE] = true

#Remove the annoying irb(main):001:0 and replace with >>
IRB.conf[:PROMPT_MODE]  = :SIMPLE

#Always nice to have auto indentation
IRB.conf[:AUTO_INDENT]  = true

#History configuration
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"

#Load modules if not already loaded
IRB.conf[:LOAD_MODULES] = []  unless IRB.conf.key?(:LOAD_MODULES)
unless IRB.conf[:LOAD_MODULES].include?('irb/completion')
  IRB.conf[:LOAD_MODULES] << 'irb/completion'       #Autocompletion of keywords
  IRB.conf[:LOAD_MODULES] << 'irb/ext/save-history' #Persist history across sessions
end     

begin
  # load wirble
  require 'wirble'

  # start wirble (with color)
  Wirble.init
  Wirble.colorize
rescue LoadError => err
  warn "Couldn't load Wirble: #{err}"
end
