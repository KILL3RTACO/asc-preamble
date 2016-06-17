Journey          = require "../journey"
{Player, Weapon} = require "../asc"
Preamble         = require "../preamble"
{AI}             = Preamble

NAME           = ""
CLASSIFICATION = null
KINGDOM        = null
GENDER         = null
WEAPON_TYPE    = null

weaponChosen = false

populate = (combo, ascEnum) ->
  values = ascEnum.values()
  combo.setItems(v.getName() for v in values)
  return combo

module.exports =

  done: (doneFn) ->
    wwt.util.validateFunction "doneFn", doneFn
    @__doneFn = doneFn

  start: ->
    Journey.reset()
    Journey.getMainContent().append "
      <div id='PreambleRegBanner'>
        #{AI.IRIS.beginTransmissionHtml()}<br/><br/>
        Welcome, challenger, to the 36<sup>th</sup> Celebration of War.<br/><br/>

        My name is #{AI.IRIS.getNameHtml()}. I am the manager of this arena; my fellow AIs and I
        work together in ensuring the arena is as harsh of a environment as it is humane. As this is the third iteration (and the only implentation) of a floor-based arena,
        some vast improvements have been made. However, we always have new ideas that need to be tested, so be on the lookout for new weapons to use
        and new monsters to fight!<br/><br/>

        It is highly possible that you will encounter other challengers/players. Because this arena is more similar to a race than a tournament, engaging in combat
        <b>is optional</b>. Remember - unsportman-like conduct (such as the intentional maiming or critical injuring of another challenger) will not be tolerated.
        Punishment can range anywhere between disqualification to being charged with an <b><i>Act of Injustice Towards Humanity</i></b>.<br/><br/>

        I have sent you the registration form to be allowed entrance into the arena. Please <i>double-check</i> all information before submitting.<br/><br/>
        #{AI.IRIS.endTransmissionHtml()}
      </div>
      <div style='margin: 1em 0; text-align: center; font-size: 16pt'>Registration Form</div>
    "
    regForm = new wwt.Composite(Journey.getMainContent(), "PreambleRegForm")

    NAME  = ""
    CLASSIFICATION = Player.ClassificationType.values()[0]
    GENDER = Player.Gender.values()[0]
    KINGDOM = Player.Kingdom.values()[0]
    WEAPON_TYPE = CLASSIFICATION.getNormalWeaponTypes()[0]

    new wwt.Label(regForm, "nameLabel").setText("Name:")
    name = new wwt.Text(regForm, "name").setPlaceholder("Full Name")
    new wwt.Label(regForm, "classLabel").setText("Classification:")
    classification = populate(new wwt.Combo(regForm, "classification"), Player.ClassificationType).setText(CLASSIFICATION.getName())
    new wwt.Label(regForm, "genderLabel").setText("Gender:")
    gender = populate(new wwt.Combo(regForm, "gender"), Player.Gender).setText(GENDER.getName())
    new wwt.Label(regForm, "kingdomLabel").setText("Hailing Kingdom:")
    kingdom = populate(new wwt.Combo(regForm, "kingdom"), Player.Kingdom).setText(KINGDOM.getName())
    new wwt.Label(regForm, "weaponLabel").setText("Weapon of Choice:")
    weapon = populate(new wwt.Combo(regForm, "weapon"), Weapon.Type).setText(WEAPON_TYPE.getName())

    cancel = Journey.getButton(0, 0)
    submit = Journey.getButton(1, 0)

    name.addListener wwt.event.Modify, (event) ->
      INVALID_NAME = /[^0-9\-A-z]/
      if INVALID_NAME.test event.value
        event.canceled = true
        return

      NAME = event.value
      submit.setEnabled(NAME isnt null and NAME.length > 0)

    classification.addListener wwt.event.Selection, (event) ->
      CLASSIFICATION = Player.ClassificationType.values()[event.index]
      if not weaponChosen
        weaponType = CLASSIFICATION.getNormalWeaponTypes()[0].getName()
        weapon.setText weaponType
        WEAPON_TYPE = weaponType
    gender.addListener wwt.event.Selection, (event) -> GENDER = Player.Gender.values()[event.index]
    kingdom.addListener wwt.event.Selection, (event) -> KINGDOM = Player.Kingdom.values()[event.index]
    weapon.addListener wwt.event.Selection, (event) ->
      WEAPON_TYPE = Weapon.Type.values()[event.index]
      weaponChosen = true

    cancel.setEnabled().setText("Cancel").addListener wwt.event.Selection, -> Preamble.mainMenu()
    submit.setText("Submit").addListener wwt.event.Selection, =>
      @__doneFn.call() if typeof @__doneFn is "function"

  getName: -> NAME
  getClassification: -> CLASSIFICATION
  getKingdom: -> KINGDOM
  getGender: ->  GENDER
  getWeaponType: -> WEAPON_TYPE
