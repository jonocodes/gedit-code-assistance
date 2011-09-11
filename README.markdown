_gedit code assistance is a plugin for gedit which provides code assistance for
C, C++ and Objective-C by utilizing clang._

# Screenshot
![gedit clang plugin](http://people.gnome.org/~jessevdk/gedit-clang-rev1.png)

# Installation from git

1. Clone the repository:

		git clone git://github.com/jessevdk/gedit-code-assistance.git

2. Install the dependencies for your distribution (packages names can differ):

	* gedit-devel (>= 3.0)
	* llvm-devel (>= 2.8)
	* vala
	* libgee-devel

3. Then run the standard autogen/make sequence:

		./autogen.sh
		make
		make install

__Note__: _To install the plugin locally, use the --enable-local configure flag. This will
install the plugin in $HOME/.local/share/gedit/plugins_
