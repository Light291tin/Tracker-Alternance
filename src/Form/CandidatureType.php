<?php

namespace App\Form;

use App\Entity\Candidature;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\Extension\Core\Type\UrlType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class CandidatureType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('company', TextType::class, [
                'label' => 'Nom de l\'entreprise',
                'attr' => ['placeholder' => 'Ex: Google, Boulangerie du Coin...']
            ])
            ->add('jobTitle', TextType::class, [
                'label' => 'Intitulé du poste',
                'attr' => ['placeholder' => 'Ex: Développeur Web Alternant']
            ])
            ->add('status', ChoiceType::class, [
                'label' => 'Statut actuel',
                'choices' => [
                    'À envoyer' => 'À envoyer',
                    'Envoyé 📩' => 'Envoyé',
                    'Entretien 🤝' => 'Entretien',
                    'Refusé ❌' => 'Refusé',
                    'Accepté 🎉' => 'Accepté',
                ],
            ])
            ->add('link', UrlType::class, [
                'label' => 'Lien de l\'offre (Optionnel)',
                'required' => false,
                'attr' => ['placeholder' => 'https://...']
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Candidature::class,
        ]);
    }
}