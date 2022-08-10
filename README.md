###




## Some Considerations On OSX  

#### DS9 Command Line  
DS9 will not run on command line as it will on linux  
A function can restore this functionality  
```
ds9(){
    # -n: new window
    # -W: wait until app closes to continue
    # -a: application
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
