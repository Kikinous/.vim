syn region texZone      start="\\begin{verbatim}"           end="\\end{verbatim}\|%stopzone\>"  contains=@Spell
syn region texZone      start="\\begin{center}"             end="\\end{center}\|%stopzone\>"    contains=@NoSpell
syn region texZone      start="\\"                          end="\r"                            contains=@NoSpell
