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
      TITLE = "Air Output"
      
      def execute_for(cmd)
        path = doc.path
        command = "#{cmd} \"#{path}\""
        output =  `#{command} 2>&1`
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
        libs_path = doc.path.split('/')
        libs_path.pop
        libs_folder = libs_path.push('libs').join('/')
        libraries = []
        Dir.entries(libs_folder).each{|f| libraries << "#{libs_folder}/#{f}" if f[/\.swc/]} if File.directory?(libs_folder)
        libraries = libraries.size > 0 ? "-library-path+=#{libraries.join(',')}" : ''
        execute_for "amxmlc #{libraries}"
      end
    end
    
    class RunAirApp < RedcarAir::ExecuteCommand
      def execute
        execute_for 'adl'
      end
    end
  end
end