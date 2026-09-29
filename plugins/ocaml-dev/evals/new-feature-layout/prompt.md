---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

I maintain a therapist scheduling web app built with Eliom on the Ocsigen Start template
(files like `tp_services.eliom`, `tp_handlers.eliom`, `tp_container.eliom`, `tp_db.ml`
already exist). I need to add a "protocols" feature: a `/protocoles` page listing the
practitioner's protocols, plus create, rename and delete actions. The page must also work
when opened from the mobile (Cordova) build. Which files do I create, which services do I
define (methods, parameters), where do I register them, and how does the client get the list
of protocols without slowing down the page? Give me the skeleton of each file.
