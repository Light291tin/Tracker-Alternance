<?php

namespace App\Controller;

use App\Repository\ApplicationRepository; // Important pour récupérer tes données
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    // 1. PAGE D'ACCUEIL (La page avec les boutons Connexion / Inscription)
    // C'est la route "/" (la racine du site)
    #[Route('/', name: 'app_landing')]
    public function landing(): Response
    {
        // Si l'utilisateur est déjà connecté, on ne lui montre pas l'accueil,
        // on l'envoie direct sur son dashboard (la montagne).
        if ($this->getUser()) {
            return $this->redirectToRoute('app_home');
        }

        return $this->render('home/accueil.html.twig');
    }

 #[Route('/dashboard', name: 'app_home')]
    public function index(ApplicationRepository $applicationRepository): Response
    {
        $this->denyAccessUnlessGranted('IS_AUTHENTICATED_FULLY');

        return $this->render('home/index.html.twig', [
            // On utilise 'candidatures' car c'est ce que ton fichier Twig attend
            'candidatures' => $applicationRepository->findBy(['user' => $this->getUser()]),
        ]);
    }
}