@def title = "Franklin Example"
@def tags = ["syntax", "code"]

# Asciinema Demo

~~~
<div id="demo"></div>
<script src="/libs/asciinema/asciinema-player.min.js"></script>
<script>
AsciinemaPlayer.create('/assets/scripts/yao.cast', document.getElementById('demo'));
</script>
~~~

\input{julia}{/assets/scripts/handson.jl}
