---
categories:
- Projects
date: 2015-06-28T00:00:00Z
draft: true
tags:
- development
- project management
- genetics
- desktop
title: VarSeq
url: /2015/06/28/project-varseq/
---

In late 2013, Golden Helix started development on a new desktop tool called VarSeq. It aims to solve many of the difficulties both researchers and clinicians experience when analyzing Next Generation Sequencing (NGS) data. It's use in a bioinformatics pipeline is just downstream of variant calling and relies on VCF files as its input.

I took on a broad leadership role in the project. I worked both as a Project Manager and as a Developer.

{{< figure src="/images/project-varseq/varseq.png" caption="The VarSeq user interface balances data density with usability. Rare variant analysis can be very complex, but by partitioning the filter chain and providing immeadiate feedback analysis can be performed rapidly." >}}

As Project Manager I was responsible for generating feature-level specification through interactions with a variety of stakeholder. Next, I would work with a technical architect to scope and produce technical specifications. Working with the project's team of developers, I was then responsible for the creation of the product's roadmap and development timeline. And as development progress, I communicated the development's teams progress with sales, marketing and management.

When possible I worked as a developer on the project as well constructing key pieces of the product. Maintaining a deep understanding of the technical underpinnings of the product allowed me to be aware of what was easy, what was possible, and what was infeasible. This understanding helped to guide stakeholder conversations and prioritization of features during roadmap planning.

### Workflow Development

One of my primary responsibilites on VarSeq was to develop the analysis workflows that shipped with the software. By default, VarSeq ships with three templates to apply to data -- cancer gene panel, herediatary gene panel, and an rare disease workflow to be applied to whole genome or exome data. The goal of these templated workflows was to give the user a starting point for analysis which delivered good results across a wide range of input data. Additionally, these templates should be easily understood, so that users can extend and refine them to suit their individual needs.

Stakeholder interviews drove the development from start to finish. A variety of users were recruited and interviewed about their analysis workflows. Representitive personas were constructed (bioinformatician, clincian, researcher, student). Additionaly, the common elements from each analysis type were combined in filters that would be applied to data. These "filter chains" were mocked up and each user was interviewed about the proposed elements. The filter chains were revised and implement as prototypes in an early version of the software. Users were interviewed while they used the software. Their feedback drove additional revisions to both the individual filtering parameters and the user interface used when running and customizing the analysis. Another round of prototyping was performed with users, before the designs were finalized.

Each analysis type has a different objective and a different target user. For example, gene panels are often analyze by less experienced personel who have very strict parameters surrounding what variants are to be reported. Thus, the filter chain in this case consists of very simple filters that do little in the way of inference. Mainly variants of poor quality, outside of target amplicons, and those that do not alter the protein sequence are removed. The remaining variant are displayed in a very straight-forward manner grouped by gene.

This contrasts with the rare disease template, which applies many filters both in sequence and parrallel to look for variants by inheritence type. Whole Exome and Genome sequencing is often performed by a very seasoned users who understand the trade-offs as filters perform more inference during analysis. A good example is looking for compound heterozygous mutations. It is two computationally expensive to examine all the pairs of variants on each gene, therefore deciding when to apply this filter is critically important. From our interviews, it is usually common to apply it after common, low quality, and non-deleterious variants have been removed. Since these users are more experience the data density is also much higher in this analysis template.

Effective workflow and user interface design are critically important in scientific software. Maintaining clarity and simplicity, while not losing power-user features was my prime consideration as the Product Manager of VarSeq. 


### Transcript Annotation

{{< figure src="/images/project-varseq/anntx.png" caption="Example transcript annotation output" >}}

A key piece of any NGS workflow is annotate each variant against the transcripts it overlaps. However, the term annotation is a misnomer for what this process entails. A more descriptive term is model-free variant effect prediction.

A single genetic variant can be predicted to have a multitude of different effects depending on which transcript is used to make the prediction. A gene often is constructed from a set of transcripts. Each of these transcripts may have different coding regions. Thus, in one transcript the variant may only impact a non-coding, intronic region, while in another it creates a premature stop codon. The biological consequence of these effects is substantially different. One of the central problems faced during development was how to present these varying effect to the user.

The algorithm followed the general form of a production system, where inferences from the genetic variant are made. Generally the inferences were ordered in increasing computational complexity, such that once a sufficent number of inferences were made the algorithm would kick out the ontology. For example, the algorithm first checked to see if the variant overlapped any transcript, if not the algorithm could terminate early and label the variant as intergenic. If however, the algorithm did overlap a transcript, it would then check for an overlapping exon. Finding one, it would check if it was coding. Seeing that it was coding, the amino acid change would be calculated. Then the variant would be classified as synonomous or non-synonomous. This process would continue until the classification was unambigious (as encoded by termination points defined from the sequence ontology database).

In order to provide clinicians and researchers with other pertinent data that was produced during the classification process such as percent of coding sequence truncated.

The algorithm was designed from the ground up to only make the minimum number of required calculation to return the data requested by the user. If the user only is interested in exon number, no computations to determine sequence ontology will be performed. This architecture allows the algorithm to be run in an on demand fashion.

Finally, in order to ensure correctness and maintainability an extensive set of unit and integration tests were written for the algorithm. These tests consisted of hand currated set of simulated variants designed expose known trouble spots for variant classification such as splicing variants.

### Internal Variant Database Interface

{{< figure src="/images/project-varseq/vardb.png" caption="Example input screen to variant assement database" >}}

From the earliest stakeholder interviews, it was apparent that users need a way to way to track their variant observations across projects. To meet this need, we developed a variant assement database.

I worked on the front-end implementation of this feature. The key aspects of its fuctionality were:

* Easily extensible - a new widget can be added simply by implementing a single class
* Fully customizable - users can select which widgets define the fields in their database
* Intgration with annotation framework - a database can be used in the same way as any other annotation track
* Track assesment changes over time - each variant show a time line edits made over time tracking both timestamp and user with the ability to rollback to any previous state
* Support for a range of database backends -- it supports both lightweight, local Sqlite installs as well as commerical-grade remote Postgres servers

### Evernote Javascript Api Integration

{{< figure src="/images/project-varseq/evernote.jpg" caption="Evernote client integrated in GenomeBrose" >}}

I'm a huge Evernote user. For my money, nothing beats some freeform notes with a screenshot or two to help you remember the context you were using when returning to project. To make this context gathering easier we [integrated Evernote directly into VarSeq and GenomeBrowse](http://blog.goldenhelix.com/ajesaitis/a-transcription-factor-for-genomebrowse-using-evernote-to-enable-sharing-genomic-analysis/).

For this project, I worked on backend due to an interesting way the Evernote API is exposed. The main API to evernote is in written in Javascript. There actually is a C++ implementation, but it requires Boost libraries and our stack is based on QT. So the best way forwarded was to wrap the JS api in C++ (I know, crazy!). It turns out this is actually relatively easy in QT. This was accomplished by using QT's WebEngine as a JS excecution enviroment. Then each call (and any dynamic processing) was wrapped by a C++ hook. In the end we created an Evernote client that exposed all basic functionality (login, notebook selection, text editing, etc) that was embedded in a cross-platform desktop appliction.

### Clinical Reporting

{{< figure src="/images/project-varseq/reportoutput.jpg" caption="Evernote clincal report rendered to pdf" >}}

VarSeq also includes the ability to create clinical grade reports. I worked as the lead front-end engineer for this project. The goals of the reporting engine were three-fold:

* Highly customizable output that can be tailored to individual lab needs
* Cross device (and medium) display of reports
* Separatation of data that changes on a lab, project, and patient basis

Here I leveraged technology built in previous projects: specifically the dynamic form interface from the variant assesment database and the use of QT's WebEngine used in the evernote integration. The finished product allows an end user to define their input form programatically in JSON. This definition is bundled with data processing code written in JavaScript and a [Handlebars](http://handlebarsjs.com/) template. This package forms the core of a WebApp that is executed in a pseudo-server/client context. The QT's WebEngine acts a "server" execution enviroment. The produced Html is then handed to a WebKit frame where further rendering can take place on the "client". One nice by product of this architecture is that it makes the module easily extensible into a more traditional WebApp execution enviroment.

The final report's customizability is only limited by the WebEngine/WebKit implementations used by QT. In fact, the final output is not restricted to Html. I built a prototype integration using XML as API interface layer for communcation with another provider.

