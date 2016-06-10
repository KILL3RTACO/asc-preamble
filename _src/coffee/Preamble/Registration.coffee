Journey   = require "../journey.js"
Player    = require "../Asc/Player.js"
AscWeapon = require "../Asc/Weapon.js"
Preamble  = require "../preamble.js"
AI        = require "./AI.js"

NAME           = ""
CLASSIFICATION = null
KINGDOM        = null
GENDER         = null
WEAPON_TYPE    = null

weaponChosen = false

populate = (combo, ascEnum) ->
  values = ascEnum.values()
  combo.setItems(v.getName() for v in values).setText(values[0].getName())
  return combo

module.exports =

  done: (doneFn) ->
    wwt.util.validateFunction "doneFn", doneFn
    @__doneFn = doneFn

  start: ->
    Journey.reset()
    Journey.getMainContent().append "
      <div id='PreambleRegBanner'>
        Hello there, challenger. My name is #{AI.IRIS.getDesignationHtml()}, but you can simply call me #{AI.IRIS.getNameHtml()}.
        In case you are new here, allow me to explain why this arena was created.<br/></br>

        As you undoubtedly know from your History courses, Anavasi has undergone some violence in the past. You humans have designated this period of time
        as 'The Old Wars.' While there was no clear 'winner' (as there wasn't meant to be), the Five Kingdoms created the Arena Tradition. Every year, challengers
        face off in the arena towards a common goal. The arena is held in a different kingdom with each iteration, and the residing kingdom is allowed to alter their
        arena as they see fit, however each change must be submitted and accepted by the Anavasi Council. This year marks the 63rd iteration of this tradition, with
        the arena being held in (City or something), Helix, [some other descriptor].<br/><br/>

        Helix never fails to impress with their technology. This year, they have prepared the biggest arena Anavasi has seen to date, setting the bar for future arenas.
        The arena has 100 floors, each varying in size, with a hidden boss monster you must defeat in order to gain access to the next floor. Engaging other challengers/players
        in combat is <i>optional</i> this year. You <i>will</i> encounter other players, and you may help or attack them at your own discretion. Likewise, be wary of other
        players, as they may not be as friendly as you believe them to be.<br/><br/>

        Below is the registration form to be allowed entrance into the arena. Please <i>double-check</i> all information before submitting.
      </div>
      <div style='margin: 1em 0; text-align: center; font-size: 16pt'>Registration Form</div>
    "
    regForm = new wwt.Composite(Journey.getMainContent(), "PreambleRegForm")

    new wwt.Label(regForm, "nameLabel").setText("Name:")
    name = new wwt.Text(regForm, "name").setPlaceholder("Full Name")
    new wwt.Label(regForm, "classLabel").setText("Classification:")
    classification = populate(new wwt.Combo(regForm, "classification"), Player.ClassificationType)
    new wwt.Label(regForm, "genderLabel").setText("Gender:")
    gender = populate(new wwt.Combo(regForm, "gender"), Player.Gender)
    new wwt.Label(regForm, "kingdomLabel").setText("Hailing Kingdom:")
    kingdom = populate(new wwt.Combo(regForm, "kingdom"), Player.Kingdom)
    new wwt.Label(regForm, "weaponLabel").setText("Weapon of Choice:")
    weapon = populate(new wwt.Combo(regForm, "weapon"), Player.Type).setText(AscCharacter.ClassificationType.AURORA.getNormalWeaponTypes()[0].getName())

    cancel = Journey.getButton(0, 0)
    submit = Journey.getButton(1, 0)

    name.addListener wwt.event.Modify, (event) ->
      NAME = event.value
      submit.setEnabled(NAME isnt null and NAME.length > 0)

    classification.addListener wwt.event.Selection, (event) ->
      CLASSIFICATION = Player.ClassificationType.values()[event.index]
      if not weaponChosen
        weaponType = CLASSIFICATION.getNormalWeaponTypes()[0].getName()
        weapon.setText weaponType
        WEAPON = weaponType
    gender.addListener wwt.event.Selection, (event) -> GENDER = Player.Gender.values()[event.index]
    kingdom.addListener wwt.event.Selection, (event) -> KINGDOM = Player.Kingdom.values()[event.index]
    weapon.addListener wwt.event.Selection, (event) ->
      WEAPON = AscWeapon.Type.values()[event.index]
      weaponChosen = true

    cancel.setEnabled().setText("Cancel").addListener wwt.event.Selection, -> Preamble.mainMenu()
    submit.setText("Submit").addListener wwt.event.Selection, => @__doneFn() if typeof @__doneFn is "function"

  getName: -> NAME
  getClassification: -> CLASSIFICATION
  getKingdom: -> KINGDOM
  getGender: ->  GENDER
  getWeaponType: -> WEAPON_TYPE
