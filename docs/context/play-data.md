# Play data and cardio context

Thraximundar is used for enjoyable aerobic exercise with friends and family. The owner has played DDR, ITG, and StepMania since 1998 and is interested in session duration and estimated cardio expenditure.

Owner-approved estimate inputs: Kyle is a 42-year-old man, 6 ft 5 in tall, and 240 lb. The desired output is estimated calories burned. These values may be stored in this public repository, but raw wearable data and detailed household health records remain private unless separately authorized.

## Available local data

- ITGMania local profile `Stats.xml` files contain cumulative and score history data.
- `Save\Upload\*.xml` contains per-session export material.
- `Thraximundar-Backup` generates recent play-time and score summaries from backed-up data.
- GrooveStats can provide online score history for configured profiles.

## Interpretation rules

- Separate song time from wall-clock session duration and label which measure is used.
- Do not treat dance-chart difficulty or score percentage as a direct calorie measurement.
- Calorie estimates should be presented as ranges, not medical measurements, and should state whether they use session time, active song time, heart rate, or a generic activity-intensity model.
- Prefer wearable heart-rate/energy data when the owner explicitly connects or exports it, and document device and algorithm limitations.
- Preserve household profile privacy; do not aggregate or publish individual health inferences without permission.
