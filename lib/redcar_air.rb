module Redcar
  class RedcarAir
    def self.keymaps
      osx = Keymap.build("main", :osx) do
        link "Cmd+Shift+C", RedcarAir::CompileToSWF
        link "Cmd+R", RedcarAir::RunAirApp
      end
      
      linwin = Keymap.build("main", [:linux, :windows]) do
        link "Ctrl+Shift+C", RedcarAir::CompileToSWF
        link "Ctrl+R", RedcarAir::RunAirApp
      end
      
      [linwin, osx]
    end
    
    def self.menus      
      Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "Air" do
            item "Compile into SWF", RedcarAir::CompileToSWF
            item "Run Current Air App", RedcarAir::RunAirApp
          end
        end
      end
    end
    
    class ExecuteCommand < Redcar::EditTabCommand
      TITLE = "Output"
      
      def execute_for(cmd)
        path = doc.path
        command = "#{cmd.to_s} \"#{path}\""
        output = `#{command} 2>&1`
        tab = output_tab
        title = "[#{DateTime.now}]$ #{command}"
        tab.document.text = "#{tab.document.to_s}" +
          "#{"="*title.length}\n#{title}\n#{"="*title.length}\n\n#{output}"
        tab.title = TITLE
        tab.focus
      end
      
      def output_tab
        tabs = win.notebooks.map {|nb| nb.tabs }.flatten
        tabs.detect {|t| t.title == TITLE} || Top::NewCommand.new.run
      end
    end
    
    class CompileToSWF < RedcarAir::ExecuteCommand
      def execute
        execute_for :amxmlc
      end
    end
    
    class RunAirApp < RedcarAir::ExecuteCommand
      def execute
        execute_for :adl
      end
    end
  end
end