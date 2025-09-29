---
status: "accepted"
date: 2025-09-29
deciders: Jon Sharpe, Daniel Wagner-Hall, Karen Klein
consulted: Adedayo Adesegun, Ali Nosratipour, Anna Hrychaniuk, Berkeli H, Borja Lorente, Cagla Akin, Craig D'Silva, Beki Meigag, Elhadj Abdoul Diallo, Dayeon Lee, Golden Mac-Eteli, Matt Stevenson, Peter Mudra
informed: \#cyf-tech-products
---
# Inter-service communication: Prefer delegated authority where possible

## Context and Problem Statement

Increasingly, CYF has multiple services which want to share data between each other. The first systems which had this need opted to duplicate that information for convenience, but this is not a scalable or maintainable solution. Currently most that data is primarily owned by the Dashboard ("CYF Core API"), and is duplicated into Classplanner, but increasingly other systems (such as the Trainee Tracker) want to access similar data.

## Considered Options

* Accessing or sharing databases directly
* API access via powerful service tokens, with each client service gaining broad access to server service data, and making individual authorisation decisions
* API access via delegated authority, with each client service passing credentials on behalf of a request's originating user

## Decision Outcome

Chosen option: API access via delegated authority, because it:
* Minimises duplication across services
* Reduces the likelihood of accidentally leaking or destroying sensitive information
* Allows for internal re-implementation of individual services without coordination, as long as the published API doesn't change

### Confirmation

When new APIs are exposed by services, they include a declaration of expected stability. Automated tests should be added for (at least the schema of) any claimed stability which will notify teams when they are breaking external promises.

Confirmation of delegated authority specifically is left as a per-review exercise to the relevant teams.

## More Information

See [this initial proposal document for briefing context](https://docs.google.com/document/d/1zBzs2-LFOJFK-3b4fXqQ28Q1pf5hZv1vHFC9YcEfJ8I/edit). This ADR was discussed and agreed at the tech-products in-person meet-up on 2025-09-20.

## Action items

### Investigate and deploy an identity provider

[Borja suggests that Supabase (currently being deployed by Devops) could be a reasonable identity provider](https://docs.google.com/document/d/1NyoezZz7P3wAROoAl51abvRUWjIa3Iw2yu6EbhQEWLU/edit). The Devops team are deploying Supabase and we will experiment with this when it's deployed.

### Collect roles

The identity provider will need to support different roles such as "Trainee", "Volunteer", "Volunteer in Glasgow", etc. We should collect the kind of role queries we may want to ask an identity provider.

We may want to use GitHub teams or similar for this.

This needn't be an up-front exercise, we can do this on-demand as we develop more APIs.

### Prototype locations without authorisation

The Classplanner team will prototype a "Locations" API from the CYF API, try changing Classplanner to use it rather than duplicating its own list of Locations, and see what troubles they run into.

## Advertise and maintain stable APIs

It was agreed that API modifications will be discussed on Slack, initially in #cyf-tech-products.

## Terminology

We have agreed a [common glossary of terminology](https://docs.google.com/document/d/1e7o7LSKTwtBFGwFESXjW_QsmqhsSK5buoshlpL0AVoA/edit) for using across APIs. These must be used in APIs where applicable, but are optional for use in UIs.

There is no urgent need to adopt this terminology in existing code, but it should be preferred in new code, and particularly in new APIs.
