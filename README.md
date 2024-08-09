# create_apptainer.sif
With this repository, we want to use apptainer to create sustainable environments for scientific reproduction.

## Utilisation

Modify one script, image.def for example, or create a new one, and make sure that the workflows you use the right script to build the apptainer environment. 
Then you can check the id of the run and use the apptainer environment to render a paper in (render_project)[https://github.com/Qufst/run_sif_and_deploy]. Or you can import the artifact manually.

We also want to push apptainer environments on Zenodo, so we use https://github.com/DiamondLightSource/zenodo-uploader method.
