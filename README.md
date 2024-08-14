# create_apptainer.sif
With this repository, we want to use apptainer to create sustainable environments for scientific reproduction.
For utilisation, clone this repository
To use Zenodo, you first need to create a repository and verify the repository ID. You also need to create a TOKEN and place it in your github repository secret.


## Utilisation

Modify one script, image.def for example, or create a new one, and make sure that the workflows you use the right script to build the apptainer environment.

Github artifact utilisation: 

- In the workflows, comment on the publication part on zenodo
- You can check the id of the run and use the apptainer environment to render a paper in (render_project)[https://github.com/Qufst/run_sif_and_deploy]. Or you can import the artifact manually.

We also want to push apptainer environments on Zenodo, so we have the second method:

- in the workflows, comment out the artifact publication part.
- in the zenodo.sh script, change the version and release date to match expectations, otherwise the release will fail