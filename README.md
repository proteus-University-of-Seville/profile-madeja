# Requirements Engineering (MADEJA)

Bilingual (English/Spanish) [PROTEUS](https://github.com/proteus-University-of-Seville/proteus-core) profile for requirements engineering following the MADEJA method, extending the `basic` profile archetypes with business analysis, requirements, conceptual modeling and requirements management categories.

## Usage

Clone this repository and select it as the profile of PROTEUS in either of these ways:

- **From PROTEUS**: click *Settings* in the *Home* tab (*Application* group). In the *Profile*
  group of the dialog, check *Check to use a custom profile*, select the folder of the
  profile and click *OK*.
- **Editing the `proteus.ini` file** of PROTEUS, with the application closed:

  ```ini
  [settings]
  using_default_profile = False
  custom_profile_path = /path/to/profile-madeja
  ```

PROTEUS loads the profile at start-up, so restart it in both cases. Then create a project from
one of the project archetypes (in English or Spanish, depending on the language of PROTEUS):

- **MADEJA RE** / **MADEJA IR** (`madeja-project-archetype` / `arquetipo-proyecto-madeja`): a
  System Requirements Specification (ERS) and a System Analysis Document (DAS) with the
  sections of the MADEJA templates, each one with a guidance comment that explains its
  content and the archetypes to use in it.
- **Municipal Sports Center (MADEJA example)** / **Centro Deportivo Municipal (ejemplo
  MADEJA)** (`sample-sports-center` / `ejemplo-centro-deportivo`): a complete sample ERS and
  DAS of a booking system for the facilities of a municipal sports center, with the same
  guidance comments followed by examples of the archetypes (organizations, people and
  figures are fictitious). The diagrams of the English example are in Spanish.

The documents of both project archetypes can also be added to an existing project as document
archetypes.
