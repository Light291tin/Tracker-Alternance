<?php

namespace App\Form;

use App\Entity\Application;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\Extension\Core\Type\DateType;
use Symfony\Component\Form\Extension\Core\Type\DateTimeType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class ApplicationType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('company', TextType::class, [
                'label' => 'Nom de l\'entreprise',
                'attr' => ['placeholder' => 'Ex: Google, Thales...']
            ])
            ->add('platform', TextType::class, [
                'label' => 'Site / Plateforme',
                'attr' => ['placeholder' => 'Ex: LinkedIn, Indeed...']
            ])
            // AJOUT DU CHAMP LIEN ICI
            ->add('link', TextType::class, [
                'label' => 'Lien de l\'offre (Optionnel)',
                'required' => false,
                'attr' => ['placeholder' => 'https://...']
            ])
            ->add('appliedAt', DateType::class, [
                'widget' => 'single_text',
                'label' => 'Date de la candidature',
            ])
            ->add('status', ChoiceType::class, [
                'label' => 'Statut actuel',
                'choices'  => [
                    'En attente de réponse' => 'En attente',
                    'J\'ai un entretien !' => 'Entretien',
                    'Refusé' => 'Refusé',
                    'Accepté' => 'Accepté',
                ],
                'attr' => ['class' => 'status-select'] 
            ])
            ->add('interviewDate', DateTimeType::class, [
                'widget' => 'single_text',
                'label' => 'Date et heure de l\'entretien',
                'required' => false,
                'row_attr' => [
                    'class' => 'interview-row', 
                    'style' => 'display:none;'
                ]
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Application::class,
        ]);
    }
}