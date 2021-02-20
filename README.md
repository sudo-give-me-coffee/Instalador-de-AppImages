





<table class="tg">
<thead>
  <tr>
    <th class="tg-0lax"><img src="src/appimage.png"></img></th>
    <th class="tg-0lax"><h1>Instalador de AppImages</h1></th>
    <th class="tg-0lax"><h1><a href="https://github.com/sudo-give-me-coffee/Instalador-de-AppImages/releases/download/download/appimage-installer.deb">Baixar</a></h1></th>
  </tr>
</thead>
</table>

# O que é?

## #somostodosesquizo

É uma ferramenta que faz uma instalação falsa de AppImages como se fossem pacotes Debian, bastando dar dois cliques no arquivo. A ideia é que o uso dos AppImages seja similar aos `.exe`do Windows essa ferramenta foi desenvolvida para a distribuição Linux TigerOS sob demanda

# Como instalar?

<a href="https://github.com/sudo-give-me-coffee/AppImage-as-DEB/releases/download/download/appimage-installer.deb">Baixe o pacote .deb</a> e dê dois cliques, siga as instruções na tela

# Como funciona?

Extrai o ícone e o lançador `.desktop` do AppImage e coloca em `/usr/share`, após isso registra na base de dados do `dpkg` permitindo uma fácil remoção utilizando o `apt`, `dpkg`, `Synaptic` ou `Mint Install`, outras lojas que dependem do `AppStream` como o GNOME Software não são suportadas

# Capturas de Tela

<p align=center>
<img src=screenshots/screen02.jpg/></br>
  Tela de boas vindas da instalação
  </p>

<p align=center>
<img src=screenshots/screen03.jpg/></br>
  Tela de finalização da instalação
  </p>

<p align=center>
<img src=screenshots/screen01.jpg/></br>
  Tela que previne uma instalação dupla
  </p>



