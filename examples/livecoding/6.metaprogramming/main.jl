#s delay = 5
############  Coding Muscle Training 6: Meta-programming  ############
# Please place your hand on your keyboard, type with me!
# Ready?
# 3. press SPACE to pause.
# 2. press → to move forward.
# 1. press ← to move backward.
# GO!

macro m(ex)
    protected_ex = QuoteNode(ex)
    :(println($protected_ex, " = ", $(esc(ex))))
end
