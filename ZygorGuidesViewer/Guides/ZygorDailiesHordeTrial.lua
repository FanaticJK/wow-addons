local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if UnitFactionGroup("player")~="Horde" then return end
if ZygorGuidesViewer.HordeDailiesInstalled then return end

ZygorGuidesViewer:RegisterGuide("Zygor's Horde Dailies Guides\\Grizzly Hills\\Grizzly Hills Pre-Quests",[[
	author support@zygorguides.com
	description This guide section contains the pre-quests to unlock the daily quest in the Granite Springs region of Grizzly Hills.  The Blackriver Logging Camp, Blue Sky Logging Grounds, and Venture Bay regions of Grizzly Hills do not have any pre-quests to unlock the daily quests that are available in those regions.
	step //1
		goto Grizzly Hills,16.2,47.6
		.talk Samir##26424
		..accept Filling the Cages##11984
	step //2
		goto 16.4,48.3
		.talk Budd##26429
		..'Tell him it's time to play with the ice trolls|havebuff Budd's Attention Span|q 11984
	step //3
		goto 13.2,60.5
		.' Use Budd's pet bar skill Tag Troll to have him stun a troll|petaction Tag Troll
		.' Use your Bounty Hunter's Cage on the stunned troll|use Bounty Hunter's Cage##35736
		.' Capture a Live Ice Troll|goal Captured Live Ice Troll|q 11984/1
	step //4
		goto 16.2,47.6
		.talk Samir##26424
		..turnin Filling the Cages##11984
	step //5
		goto 16.4,47.8
		.talk Drakuru##26423
		..accept Truce?##11989
	step //6
		goto 16.5,47.8
		.' Click the Dull Carving Knife|tip It's a knife stuck in the side of this tree trunk.
		.collect 1 Dull Carving Knife##38083|q 11989
	step //7
		goto 16.4,47.8
		.' Use your Dull Carving Knife next to the yellow cage|use Dull Carving Knife##38083
		.talk Drakuru##26423
		..'Shake his hand
		..'Make a Blood Pact With Drakuru|goal Blood Pact With Drakuru|q 11989/1
	step //8
		goto 16.4,47.8
		.talk Drakuru##26423
		..turnin Truce?##11989
		..accept Vial of Visions##11990
	step //9
		goto 16,47.8
		.talk Ameenah##26474
		..buy 1 Imbued Vial|q 11990/1
	step //10
		goto 14.6,45.3
		.' Click the Hazewood Bushes|tip They look like small flower bushes on the ground around this area.
		.get 3 Haze Leaf|q 11990/2
	step //11
		goto 15.2,40.3
		.' Click a Waterweed|tip They look like big green bushes underwater around this area.
		.get Waterweed Frond|q 11990/3
	step //12
		goto 16.4,47.8
		.talk Drakuru##26423
		..turnin Vial of Visions##11990
	step //13
		goto 15.7,46.7
		.talk Prigmon##26519
		..accept Scourgekabob##12484
	step //14
		goto 15.7,46.9
		.' Click a Scourged Troll Mummy on the ground next to you
		.collect 1 Scourged Troll Mummy##38149|q 12484
	step //15
		goto 16.9,48.3
		.' Use your Scourged Troll Mummy next to the burning pile of mummies|use Scourged Troll Mummy##38149
		.' Burn a Mummified Carcass|goal Mummified Carcass Burned|q 12484/1
	step //16
		goto 16.7,48.3
		.talk Mack Fearsen##26604
		..turnin Scourgekabob##12484
		..accept Seared Scourge##12029
	step //17
		goto 16,29.9
		.' Jump on the big rock and stand on it
		.' Use Mack's Dark Grog and throw it at the trolls running around to the north|use Mack's Dark Grog##35908
		.' Burn 20 Scourge Trolls|goal 20 Scourge Trolls Burned |q 12029/1
	step 18
		goto 16.7,48.3
		.talk Mack Fearsen##26604
		..turnin Seared Scourge##12029
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Horde Dailies Guides\\Grizzly Hills\\Blackriver Logging Camp Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quest in the Blackriver Logging Camp region of Grizzly Hills.  There are no pre-quests needed to unlock the daily quest offered in this guide section.
	daily
	step //1
		goto Grizzly Hills,26.4,65.8
		.talk Raider Captain Kronn##27120
		..accept Blackriver Brawl##12170 |daily
	step //2
		goto 27.3,64.7
		.' Kill Alliance Players or Amberpine Scouts in the Blackriver Logging Camp
		.' Kill 10 Alliance in Blackriver|goal 15 Alliance in Blackriver slain|q 12170/1
	step //3
		goto 26.4,65.8
		.talk Raider Captain Kronn##27120
		..turnin Blackriver Brawl##12170
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Horde Dailies Guides\\Grizzly Hills\\Blue Sky Logging Grounds Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quests in the Blue Sky Logging Grounds region of Grizzly Hills.  There are no pre-quests needed to unlock the daily quests offered in this guide section.
	daily
	step //1
		goto Grizzly Hills,33.8,32.7
		.talk Aumana##27464
		..accept Overwhelmed!##12288 |daily
	step //2
		goto 34.4,32.6
		.talk Lurz##27422
		..accept Making Repairs##12280 |daily
	step //3
		goto 34.5,32.5
		.talk Grekk##27423
		..accept Shred the Alliance##12270 |daily
	step //4
		goto 34.5,33.0
		.talk Commander Bargok##27451
		..accept Keep 'Em on Their Heels##12284 |daily
	step //5
		goto 35.2,39.3
		.' Kill Alliance Players or Wounded Westfall Infantry around the area
		.' Use Renewing Tourniquet on Wounded Skirmishers|use Renewing Tourniquet##37568
		.' Heal 10 Wounded Skirmishers|goal 10 Wounded Skirmishers Healed|q 12288/1
		.' Click Grooved Cogs, Notched Sprockets, and High Tension Springs on the ground of the Blue Sky Logging Grounds
		..get 4 Grooved Cogs##37412|q 12280/1
		..get 3 Notched Sprockets##37413|q 12280/2
		..get 2 High Tension Springs##37416|q 12280/3
	step //6
		goto 33.4,35.7
		.' Kill Alliance Players or Wounded Westfall Infantry around the area
		.' Eliminate 15 Horde units|goal 15 Horde units eliminated|q 12284/1
	step //7
		goto 32.8,40.5
		.' Find a Broken-down Shredder that spawns around this area
		.' Click the Broken-down Shredder to get inside it
		.' Use your abilities on your hot bar to return the shredder to Grekk at 34.5,32.5
		.' Deliver 3 Shredders|goal 3 Shredder Delivered|q 12270/1
	step //8
		goto 34.5,32.5
		.talk Grekk##27423
		..turnin Shred the Alliance##12270
	step //9
		goto 34.4,32.6
		.talk Lurz##27422
		..turnin Making Repairs##12280
	step //10
		goto 34.5,33.0
		.talk Commander Bargok##27451
		..turnin Keep 'Em on Their Heels##12284
	step //11
		goto 33.8,32.7
		.talk Aumana##27464
		..turnin Overwhelmed!##12288
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Horde Dailies Guides\\Grizzly Hills\\Granite Springs Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quest in the Granite Springs region of Grizzly Hills.
	daily
	step //1
		goto Grizzly Hills,16.7,48.3
		.talk Mack Fearsen##26604
		..accept Seared Scourge##12038 |daily
	step //234
		goto 16,29.9
		.' Jump on the big rock and stand on it
		.' Use Mack's Dark Grog and throw it at the trolls running around to the north|use Mack's Dark Grog##35908
		.' Burn 30 Scourge Trolls|goal 30 Scourge Trolls Burned |q 12038/1
	step //3
		goto Grizzly Hills,16.7,48.3
		.talk Mack Fearsen##26604
		..turnin Seared Scourge##12038
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Horde Dailies Guides\\Grizzly Hills\\Venture Bay Dailies",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the daily quests in the Venture Bay region of Grizzly Hills.  There are no pre-quests needed to unlock the daily quests offered in this guide section.
	daily
	step //1
		goto Grizzly Hills,14.8,86.6
		.talk General Gorlok##27708
		..accept Riding the Red Rocket##12432 |daily
		.' If he's not there, then you have to take control of Venture Bay for the Horde
		..' To take control of Venture Bay for the Horde, go to 15.1,88.0|tip Hide behind the lighthouse in between the 2 big brown rocks.  Flag yourself for PvP and a bar will appear under your minimap.  Sit here until the bar marker is all the way to the right, this will make General Gorlok spawn.
	step //2
		goto 11.4,76.7
		.talk Stone Guard Ragetotem##27606
		..accept Smoke 'Em Out##12324 |daily
	step //3
		goto 10.1,77.3
		.talk Centurion Kaggrum##27563
		..accept Keep Them at Bay##12317 |daily
	step //4
		goto 10.1,77.2
		.talk General Khazgar##27532
		..accept Crush Captain Brightwater!##12315 |daily
	step //5
		goto 18.0,79.6
		.' Toss the Smoke Bomb into the buildings to smoke out Venture Co. Stragglers|use Smoke Bomb##37621
		.' Building one can be found at 18.0,79.6
		.' Building two can be found at 16.4,76.6
		.' Building three can be found at 14.6,76.7
		.' Smoke out 20 Venture Company Stragglers|goal 20 Venture Company Stragglers smoked out|q 12324/1
	step //6
		goto 14.8,77.8
		.' Kill Alliance Players or Westfall Brigade Marine in Venture Bay
		.' Kill 10 Alliance in Venture Bay|goal 10 Alliance killed in Venture Bay|q 12317/1
	step //7
		goto 17.0,81.6
		.kill Captain Brightwater##27509|q 12315/1
	step //8
		goto 16.4,80.3
		.' Click the Element 115 in the back room of the ship|tip It looks like a red canister with a handle on the top
		..collect Element 115##37664|q 12432
	step //9
		  goto 21.4,84.5
		.' On the next step you will guide a rocket into this Alliance lumber boat
		.' Your target will be the wooden X on the side
		.' Go to 13.6,88.9
		.' You will want to use your keys, not your mouse, to guide the rocket
		.' Avoid icebergs or the rocket will explode and you will have to start over
		.' Click a red rocket to take control of one|invehicle|c|q 12432	
	step // 10
		goto 9.6,79.1
		.' Hit the wooden X on the back of the Alliance Lumber boat
		.' Destroy the Alliance Lumber boat|goal Destroyed Alliance Lumber Shipment|q 12432/1
	step //11
		goto 14.8,86.6
		.talk General Gorlok##27708
		..turnin Riding the Red Rocket##12432
		.' If he's not there, then you have to take control of Venture Bay for the Horde
		..' To take control of Venture Bay for the Horde, go to 15.1,88.0|tip Hide behind the lighthouse in between the 2 big brown rocks.  Flag yourself for PvP and a bar will appear under your minimap.  Sit here until the bar marker is all the way to the right, this will make General Gorlok spawn.
	step //12
		goto 11.4,76.7
		.talk Stone Guard Ragetotem##27606
		..turnin Smoke 'Em Out##12324
	step //13
		goto 10.1,77.3
		.talk Centurion Kaggrum##27563
		..turnin Keep Them at Bay##12317
	step //14
		goto 10.1,77.2
		.talk General Khazgar##27532
		..turnin Crush Captain Brightwater!##12315
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Horde Dailies Guides\\Events\\Lunar Festival (February 14th - March 6th)\\Lunar Festival Main Questline",[[
	author support@zygorguides.com
	description This guide section will walk you through completing the main questline for the Lunar Festival event.
	step //
		goto Orgrimmar,51.0,70.5
		.talk Lunar Festival Emissary##15891
		..accept The Lunar Festival##8873
	step //
		goto 41.6,32.0
		.talk Lunar Festival Harbinger##15895
		..turnin The Lunar Festival##8873
		..accept Lunar Fireworks##8867
	step //
		goto 41.3,32.4
		.talk Lunar Festival Vendor##15898
		..buy 8 Small Blue Rocket |q 8867
		..buy 2 Blue Rocket Cluster |q 8867
	step //
		goto 41.6,32.8
		.' Use Small Blue Rockets|use Small Blue Rocket##21558
		.' Use Blue Rocket Clusters|use Blue Rocket Cluster##21571
		.' Fire 8 Lunar Fireworks|q 8867/1
		.' Fire 2 Lunar Fireworks Clusters|q 8867/2
	step //
		goto 41.6,32.0
		.talk Lunar Festival Harbinger##15895
		..turnin Lunar Fireworks##8867
		..accept Valadar Starsong##8883
	step //
		goto 41.0,31.0
		.' Use the Lunar Festival Invitation while standing in the beam of light |use Lunar Festival Invitation##21711
		.' Go to Moonglade |goto Moonglade |c |q 8883
	step //
		goto Moonglade,53.6,35.3
		.talk Valadar Starsong##15864
		..turnin Valadar Starsong##8883
]])
ZygorGuidesViewer:RegisterGuide("Zygor's Horde Dailies Guides\\Events\\Lunar Festival (February 14th - March 6th)\\Lunar Festival Optimized Elders Path",[[
	author support@zygorguides.com
	description This guide section will walk you through an optimized path for honoring the elders that are spread out all over Azeroth for the Lunar Festival event.  The 13 elders that are inside instances are not included in this guide section.  Using this guide section, you will collect 62 of the total 75 Coins of Ancestry.
// EASTERN KINGDOMS
	step //
		goto Western Plaguelands,69.0,73.0
		.talk Elder Moonstrike##15594
		..accept Moonstrike the Elder##8714|instant
	step //
		goto Western Plaguelands,66.0,47.8
		.talk Elder Meadowrun##15602
		..accept Meadowrun the Elder##8722|instant
	step //
		.' Follow the road west to Tirisfal Glades|goto Tirisfal Glades
	step //
		goto Tirisfal Glades,61.9,53.8
		.talk Elder Graveborn##15568
		..accept Graveborn the Elder##8652|instant
	step //
		'Go south to Undercity |goto Undercity |noway |c
	step //
		goto Undercity,66.7,38.1
		.talk Elder Darkcore##15564
		..accept Darkcore the Elder##8648|instant
	step //
		goto 63.3,48.6
		.talk Michael Garrett##4551
		..' Fly to The Sepulcher |goto Silverpine Forest,45.6,42.4,0.5 |noway |c
	step //
		 goto Silverpine Forest,45.0,41.1
		.talk Elder Obsidian##15561
		..accept Obsidian the Elder##8645 |instant
	step //
		goto 45.6,42.6
		.talk Karos Razok##2226
		..' Fly to Light's Hope Chapel |goto Eastern Plaguelands,74.4,51.2,0.5 |noway |c
	step //
		goto Eastern Plaguelands,75.7,54.6
		.talk Elder Snowcrown##15566
		..accept Snowcrown the Elder##8650|instant
	step //
		goto 35.6,68.8
		.talk Elder Windrun##15592
		..accept Windrun the Elder##8688|instant
	step //
		'Go west to Western Plaguelands |goto Western Plaguelands |noway |c
	step //
		goto Western Plaguelands,69.3,49.7
		.talk Frax Bucketdrop##37888
		..' Fly to Revantusk Village |goto The Hinterlands,81.7,81.9,0.5 |noway |c
	step //
		goto The Hinterlands,49.9,47.9
		.talk Elder Highpeak
		.accept Highpeak the Elder##8643|instant
	step //
		goto 81.7,81.8
		.talk Gorkas##4314
		..' Fly to Kargath |goto Badlands,4.1,44.9,0.5 |noway |c
	step //
		'Go northeast to Loch Modan |goto Loch Modan |noway |c
	step //
		goto Loch Modan,33.0,46.5
		.talk Elder Silvervein##15558
		..accept Silvervein the Elder##8642|instant
	step //
		'Go southwest to Dun Morogh |goto Dun Morogh |noway |c
	step //
		'Go northwest into Ironforge |goto Ironforge |noway |c |tip Run in the front gates and don't stop, guards will be chasing you, and possibly players as well.  Run straight to the Elder in the next step, then immediately run back out.
	step //
		goto Ironforge,28.1,17.0
		.talk Elder Bronzebeard##15871
		..accept Bronzebeard the Elder##8866|instant
	step //
		'Go outside to Dun Morogh|goto Dun Morogh|noway|c |tip If you die trying to leave Ironforge, just resurrect at the spirit healer you get sent to.
	step //
		goto Dun Morogh,46.7,51.4
		.talk Elder Goldwell##15569
		..accept Goldwell the Elder##15569|instant
	step //
		'Go east to Loch Modan |goto Loch Modan |noway |c
	step //
		'Go southeast to Badlands |goto Badlands |noway |c
	step //
		goto Badlands,4.0,44.8
		.talk Gorrik##2861
		..' Fly to Thorium Point |goto Searing Gorge,34.8,30.6,0.5 |noway |c
	step //
		goto Searing Gorge,21.1,78.8
		.talk Elder Ironband##15567
		..accept Ironband the Elder##8651 |instant
	step //
		goto 34.8,30.9
		.talk Grisha##3305
		..' Fly to Flame Crest |goto Burning Steppes,65.6,24.2,0.5 |noway |c
	step //
		goto Burning Steppes,64.2,24.0
		.talk Elder Dawnstrider##15585
		..accept Dawnstrider the Elder##8683|instant
	step //
		goto 81.9,46.3
		.talk Elder Rumblerock##15557
		..accept Rumblerock the Elder##8636|instant
	step //
		'Go south to Redridge Mountains |goto Redridge Mountains |noway |c
	step //
		'Go southwest to Elwynn Forest |goto Elwynn Forest |noway |c
	step //
		goto Elwynn Forest,39.6,63.5
		.talk Elder Stormbrow##15565
		..accept Stormbrow the Elder##8649|instant
	step //
		'Go northwest to Stormwind City |goto Stormwind City |noway |c	|tip Run in the front gates and don't stop, guards will be chasing you, and possibly players as well.  Run straight to the Elder in the next step, then immediately run back out.  Also, if you want to take the time, you could swim to Stormwind Harbor from the northeast part of Westfall.  Doing so would allow you to have a MUCH shorter and easier run to the Elder in the next step.
	step //
		goto Stormwind City,36.0,66.0
		.talk Elder Hammershout##15562
		..accept Hammershout the Elder##8646|instant
	step //
		'Go outside to Elwynn Forest |goto Elwynn Forest |noway |c |tip If you die trying to leave Ironforge, just resurrect at the spirit healer you get sent to.
	step //
		'Go southwest to Westfall |goto Westfall |noway |c
	step //
		goto Westfall,55.6,47.0
		.talk Elder Skychaser##15577
		..accept Skychaser the Elder##8675|instant
	step //
		'Go southeast to Duskwood |goto Duskwood |noway |c
	step //
		'Go east to Deadwind Pass |goto Deadwind Pass |noway |c
	step //
		'Go east to Swamp of Sorrows |goto Swamp of Sorrows |noway |c
	step //
		'Go southeast to Blasted Lands |goto Blasted Lands |noway |c
	step //
		goto Blasted Lands,57.7,54.7
		.talk Elder Bellowrage##15563
		..accept Bellowrage the Elder##8647|instant
	step //
		'Go north Swamp of Sorrows |goto Swamp of Sorrows |noway |c
	step //
		goto Swamp of Sorrows,46.1,54.8
		.talk Breyk##6026
		..' Fly to Grom'Gol |goto Stranglethorn Vale,32.5,29.3,0.5 |noway |c
	step //
		goto Stranglethorn Vale,53.1,18.3
		.talk Elder Starglade##15596
		..accept Starglade the Elder##8716 |instant
	step //
		goto 32.5,29.4
		.talk Thysta##1387
		..' Fly to Booty Bay |goto Stranglethorn Vale,26.8,77.0,0.5 |noway |c
	step //
		goto 26.3,76.4
		.talk Elder Winterhoof##15576
		..accept Winterhoof the Elder##15576 |instant
	step //
		goto 26.0,73.2 |n
		'Ride the boat to Ratchet |goto The Barrens |noway |c
// KALIMDOR
	step //
		goto The Barrens,62.6,36.7
		.talk Elder Windtotem##15582
		..accept Windtotem the Elder##8680 |instant
	step //
		goto 63.1,37.2
		.talk Bragok##16227
		..' Fly to the Crossroads |goto The Barrens,51.5,30.4,0.5 |noway |c
	step //
		goto 51.4,30.6
		.talk Elder Moonwarden##15597
		..accept Moonwarden the Elder##8717 |instant
	step //
		goto 51.5,30.3
		.talk Devrak##3615
		..' Fly to Camp Taurajo |goto The Barrens,44.5,59.1,0.5 |noway |c
	step //
		goto 45.0,57.9
		.talk Elder High Mountain##15588
		..accept High Mountain the Elder##8686 |instant
	step //
		'Go west to Mulgore |goto Mulgore |noway |c
	step //
		goto Mulgore,48.3,53.4
		.talk Elder Bloodhoof##15575
		..accept Bloodhoof the Elder##8673 |instant
	step //
		'Go north to Thunder Bluff |goto Thunder Bluff |noway |c
	step //
		goto Thunder Bluff,72.2,23.5
		.talk Elder Ezra Wheathoof##15580
		..accept Wheathoof the Elder##8678 |instant
	step //
		goto 47.0,49.8
		.talk Tal##2995
		..' Fly to Camp Mojache |goto Feralas,75.4,44.3,0.5 |noway |c
	step //
		goto Feralas,76.7,37.7
		.talk Elder Grimtotem##15581
		..accept Grimtotem the Elder##8679 |instant
	step //
		goto 59.5,40.0
		.talk Elder Mistwalker##15587
		..accept Mistwalker the Elder##8685 |instant
	step //
		'Go outside to Feralas |goto Feralas |noway |c
	step //
		goto Feralas,75.5,44.4
		.talk Shyn##8020
		..' Fly to Cenarion Hold |goto Silithus,48.8,36.7,0.5 |noway |c
	step //
		goto Silithus,48.8,37.6
		.talk Elder Bladesing##15599
		..accept Bladesing the Elder##8719 |instant
	step //
		goto 23.1,11.8
		.talk Elder Primestone##15570
		..accept Primestone the Elder##8654 |instant
	step //
		goto 48.7,36.7
		.talk Runk Windtamer##15178
		..' Fly to Marshal's Refuge |goto Un'Goro Crater,45.3,6.0,0.5 |noway |c
	step //
		goto Un'Goro Crater,50.4,76.2
		.talk Elder Thunderhorn##15583
		..accept Thunderhorn the Elder##8681 |instant
	step //
		'Go east to Tanaris |goto Tanaris |noway |c
	step //
		goto Tanaris,36.2,80.4
		.talk Elder Ragetotem##15573
		..accept Ragetotem the Elder##8671 |instant
	step //
		goto 51.5,27.9
		.talk Elder Dreamseer##15586
		..accept Dreamseer the Elder##8684 |instant
	step //
		'Go north to Thousand Needles |goto Thousand Needles |noway |c
	step //
		goto Thousand Needles,79.0,76.9
		.talk Elder Morningdew##15604
		..accept Morningdew the Elder##8724 |instant
	step //
		goto 45.3,49.8
		.talk Elder Skyseer##15584
		..accept Skyseer the Elder##8682 |instant
	step //
		goto 45.1,49.1
		.talk Nyse##4317
		..' Fly to Ogrimmar |goto Orgrimmar |noway |c
	step //
		goto Orgrimmar,40.9,32.9
		.talk Elder Darkhorn##15579
		..accept Darkhorn the Elder##8677 |instant
	step //
		'Go outside to Durotar |goto Durotar |noway |c
	step //
		goto Durotar,53.1,43.5
		.talk Elder Runetotem##15572
		..accept Runetotem the Elder##8670 |instant
	step //
		'Go north to Orgrimmar |goto Orgrimmar |noway |c
	step //
		goto Orgrimmar,45.1,63.9
		.talk Doras##3310
		..' Fly to Valormok |goto Azshara,22.0,49.7,0.5 |noway |c
	step //
		goto Azshara,72.4,84.9
		.talk Elder Skygleam##15600
		..accept Skygleam the Elder##8720 |instant
	step //
		goto 21.9,49.6
		.talk Kroum##8610
		..' Fly to Everlook |goto Winterspring,60.5,36.3,0.5 |noway |c
	step //
		goto Winterspring,61.3,37.7
		.talk Elder Stonespire##15574
		..accept Stonespire the Elder##8672 |instant
	step //
		goto 55.6,43.6
		.talk Elder Brightspear##15606
		..accept Brightspear the Elder##8726 |instant
	step //
		goto 60.5,36.3
		.talk Yugrek##11139
		..' Fly to Bloodvenom Post |goto Felwood,34.4,53.9,0.5 |noway |c
	step //
		goto Felwood,37.7,52.9
		.talk Elder Nightwind##15603
		..accept Nightwind the Elder##8723 |instant
	step //
		goto 34.5,54.0
		.talk Brakkar##11900
		..' Fly to Zoram'gar Outpost |goto Ashenvale,12.2,33.8,0.5 |noway |c
	step //
		goto Ashenvale,35.4,48.9
		.talk Elder Riversong##15605
		..accept Riversong the Elder##8725 |instant
	step //
		'Go northwest to Darkshore |goto Darkshore |noway |c
	step //
		goto Darkshore,36.7,46.6
		.talk Elder Starweave##15601
		..accept Starweave the Elder##8721 |instant
	step //
		goto 33.2,40.1 |n
		.' Ride the boat to Rut'theran Village |goto Teldrassil |noway |c
	step //
		'Go through the pink portal to Darnassus |goto Darnassus |noway |c |tip Once in Darnassus, don't stop running, guards will be chasing you, and possibly players as well.  Run straight to the Elder in the next step, then immediately leave Dalaran out of the east exit.
	step //
		goto Darnassus,33.6,15.1
		.talk Elder Bladeswift##15598
		..accept Bladeswift the Elder##8718 |instant
	step //
		'Go out of the east exit of Darnassus to go to Teldrassil |goto Teldrassil |noway |c
	step //
		goto Teldrassil,57.2,60.7
		.talk Elder Bladeleaf##15595
		..accept Bladeleaf the Elder##8715 |instant
	step //
		'Go west to Darnassus |goto Darnassus |noway |c
	step //
		goto Darnassus,31.6,12.5
		.' Use the Lunar Festival Invitation while standing in the beam of light |use Lunar Festival Invitation##21711
		.' Go to Moonglade |goto Moonglade |c
	step //
		goto Moonglade,35.7,58.9
		.' Use the Lunar Festival Invitation while standing in the beam of light |use Lunar Festival Invitation##21711
		.' Go to Stormwind City |goto Stormwind City |c
	step //
		'Go outside to Durotar |goto Durotar |noway |c
// NORTHREND
	step //
		goto Durotar,41.3,17.7 |n
		.' Ride the zeppelin to Borean Tundra |goto Borean Tundra |noway |c
	step //
		goto Borean Tundra,42.9,49.6
		.talk Elder Pamuya##30371
		..accept Pamuya the Elder##13029 |instant
	step //
		goto 33.8,34.4
		.talk Elder Northal##30360
		..accept Northal the Elder##13016 |instant
	step //
		goto 59.1,65.6
		.talk Elder Sardis##30348
		..accept Sardis the Elder##13012 |instant
	step //
		goto 57.4,43.7
		.talk Elder Arp##30364
		..accept Arp the Elder##13033 |instant
	step //
		'Go north to Sholazar Basin |goto Sholazar Basin |noway |c
	step //
		goto Sholazar Basin,49.8,63.6
		.talk Elder Sandrene##30362
		..accept Sandrene the Elder##13018 |instant
	step //
		goto 63.8,49.0
		.talk Elder Wanikaya##30365
		..accept Wanikaya the Elder##13024 |instant
	step //
		'Go southeast to Wintergrasp |goto Wintergrasp |noway |c
	step //
		goto Wintergrasp,50.5,16.4
		.' Click the Defender's Portal
		.' Go to the upper level of the Wintergrasp Fortress |goto Wintergrasp,50.4,15.9,0.1 |noway |c
	step //	
		goto 49.0,13.9
		.talk Elder Bluewolf##30368
		..accept Bluewolf the Elder##13026 |instant
	step //
		goto 49.6,15.9
		.' Click the Defender's Portal
		.' Go to outside of the Wintergrasp Fortress |goto Wintergrasp,49.6,16.3,0.1 |noway |c
	step //
		'Leave Wintergrasp and get back on your flying mount
		.' Skip to the next step of the guide once you are back on your flying mount
	step //
		'Go southeast to Dragonblight |goto Dragonblight |noway |c
	step //
		goto Dragonblight,35.1,48.3
		.talk Elder Skywarden##30373
		..accept Skywarden the Elder##13031 |instant
	step //
		goto 29.7,55.9
		.talk Elder Morthie##30358
		..accept Morthie the Elder##13014 |instant
	step //
		goto 48.8,78.2
		.talk Elder Thoim##30363
		..accept Thoim the Elder##13019 |instant
	step //
		'Go east to Grizzly Hills |goto Grizzly Hills |noway |c
	step //
		goto Grizzly Hills,64.2,47.0
		.talk Elder Whurain##30372
		..accept Whurain the Elder##13030 |instant
	step //
		goto 80.5,37.1
		.talk Elder Lunaro##30367
		..accept Lunaro the Elder##13025 |instant
	step //
		goto 60.6,27.7
		.talk Elder Beldak##30357
		..accept Beldak the Elder##13013 |instant
	step //
		'Go northwest to Zul'Drak |goto Zul'Drak |noway |c
	step //
		goto Zul'Drak,58.9,56.0
		.talk Elder Tauros##30369
		..accept Tauros the Elder##13027 |instant
	step //
		'Go northwest to The Storm Peaks |goto The Storm Peaks |noway |c
	step //
		goto The Storm Peaks,41.2,84.7
		.talk Elder Graymane##30370
		..accept Graymane the Elder##13028 |instant
	step //
		goto 28.9,73.7
		.talk Elder Fargal##30359
		..accept Fargal the Elder##13015 |instant
	step //
		goto 31.3,37.6
		.talk Elder Stonebeard##30375
		..accept Stonebeard the Elder##13020 |instant
	step //
		goto 64.6,51.3
		.talk Elder Muraco##30374
		..accept Muraco the Elder##13032 |instant
]])