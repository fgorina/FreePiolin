# Free Piolin - On son les curses Allò 2017

Aquesta aplicaciò permet consultar si estem inscrits a les curses   **Allò 2017** i a on hem d'anar a recollir el dorsal i tenim la sortida.

Per compilar-la es necessita incorporar **CryptoSwift** amb CocoaPods.

El Podfile es trova al Git amb el projecte però si algú te problmes el seu contingut es :

```
platform :ios, '10.0'
use_frameworks!

target "onvotar" do
    pod 'CryptoSwift', '~> 0.7.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
```
Es important doncs l'aplicaciò fa servir CryptoSwift per calcular SHA256 i l'encripciò AES.

La aplicaicò es molt senzilla i no incorpora en local les dades però es poden carregar fent un tap a la i que hi ha a la primera pantalla.

En general primer intentarà anar a un URL remot i si no pot fara servir el local.

Desde la pantalla de càrrega podem descarregar la base de dades però al cap de uns 15000 fitxers peta per lo que
el programa de càrrega permet fer-ho per trams de 256 fitxers. Si feu uns 5 o 6 trams serà suficient.

Vigileu perque la Base de Dades es força gran, penseu que amb tot carregat la aplicaciò necessita uns 2,4Gb.

Ara es una mica tard per aquesta aplicaciò però sempre es interessant fer una prova per veure si entens com funcionen les coses.



