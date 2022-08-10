###




## Some Considerations On OSX  

#### WCSTools Installation  
After installing MacPorts I was able to install WCSTools
'''
sudo port install wcstools
'''

#### DS9 Installation  
Since having installed homebrew for HEASoft setup, I used homebrew to install DS9 as well.
'''
brew install --cask saoimageds9
'''

#### DS9 Command Line  
DS9 will not run on command line as it will on linux  
A function can restore this functionality  
```
ds9(){
    # -n: new window
    # -W: wait until app closes to continue
    # -a: application
    # --args: accepting a list of arguments
    # "${@}": every argument provided when calling this function, passed to ds9 due to --args

    ### NOTE
    #  Any file passed as an argument must be passed using the full absolute path
    ###

    open -n -W -a /Applications/SAOImageDS9.app/Contents/MacOS/ds9 --args "${@}"
}
```

#### Shell: zsh  
OSX uses zsh shell by default; references .zprofile (NOT .bash_profile or .bashrc)  
When switching to bash so commands in scripts run properly, bash sources .bash_profile (NOT .bashrc)  

To organize my scripts I checked for/created:  
- .zprofile  
- .bash_profile  
- .bashrc  
- .shell_profile  

.zprofile:  
    [[ -f ~/.shell_profile ]] && . ~/.shell_profile  
.bash_profile:  
    [[ -f ~/.bashrc ]] && . ~/.bashrc  
.bashrc:  
    [[ -f ~/.shell_profile ]] && . ~/.shell_profile  

I also moved my # >>> conda initialize >>> to .shell_profile

#### HEASoft Installation  

After following instructions and installing gcc & perl using homebrew; check for the version of gcc at the following location.

'''
ls /usr/local/Cellar/gcc/
ls /usr/local/Cellar/gcc/<version>/bin
'''
The instructions said to use gcc-11 but mine was actually gcc-12.

Also, triple check PYTHON env variable and config.txt to make sure (Ana)Conda python is set properly before continuing so PyXspec is installed.