# Islandora Integration Tests

Tie together [isle-buildkit](https://github.com/Islandora-Devops/isle-buildkit/) docker images, [isle-site-template](https://github.com/islandora-Devops/isle-site-template) container orchestration, [islandora-starter-site](https://github.com/Islandora-Devops/islandora-starter-site) Drupal codebase+config in order to run integration tests.

## Overview

sequenceDiagram
    actor Alice
    Alice->>GitHub: git push origin feature-branch
    GitHub->>GitHub: run test action
    GitHub->>LibOps: GET environment<br>composer-project:tag<br>buildkit:tag<br>(optional) GITHUB_TOKEN<br>(optional) module:patch
    alt environment does not exist
        LibOps->>Google Compute Engine VM: init environment
        Google Compute Engine VM-->>LibOps: ok
    end
    LibOps->>Google Compute Engine VM: drush user:password admin
    Google Compute Engine VM-->>LibOps: PASS
    LibOps->>GitHub: {<br>"password": "PASS",<br>"url": "https://example.com"<br>}
    GitHub->>GitHub: run tests on environment
    GitHub->>Google Compute Engine VM: test1
    Google Compute Engine VM-->>GitHub: ok
    GitHub->>Google Compute Engine VM: test2
    Google Compute Engine VM-->>GitHub: ok
    GitHub->>Google Compute Engine VM: testn
    Google Compute Engine VM-->>GitHub: ok
    Alice->>GitHub: reads action output
```
