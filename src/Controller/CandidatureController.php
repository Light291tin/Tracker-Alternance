<?php

namespace App\Controller;

use App\Entity\Candidature;
use App\Form\CandidatureType;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class CandidatureController extends AbstractController
{
    #[Route('/candidature/new', name: 'app_candidature_new')]
    public function new(Request $request, EntityManagerInterface $entityManager): Response
    {
        $candidature = new Candidature();
        $form = $this->createForm(CandidatureType::class, $candidature);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $candidature->setUser($this->getUser());
            $candidature->setCreatedAt(new \DateTimeImmutable());

            $entityManager->persist($candidature);
            $entityManager->flush();

            return $this->redirectToRoute('app_home');
        }

        return $this->render('candidature/new.html.twig', [
            'form' => $form->createView(),
        ]);
    }

    #[Route('/candidature/{id}/update-status', name: 'app_candidature_update_status', methods: ['POST'])]
    public function updateStatus(Candidature $candidature, Request $request, EntityManagerInterface $entityManager): Response
    {
        $token = $request->request->get('_token');
        if ($this->isCsrfTokenValid('update_status' . $candidature->getId(), $token)) {
            
            // 1. On récupère les infos
            $newStatus = $request->request->get('status');
            $dateString = $request->request->get('interviewDate'); // Important !
            
            // 2. On met à jour le statut
            $candidature->setStatus($newStatus);

            // 3. Si c'est un entretien, on enregistre la date
            if (str_contains($newStatus, 'Entretien')) {
                if (!empty($dateString)) {
                    try {
                        $candidature->setInterviewDate(new \DateTime($dateString));
                    } catch (\Exception $e) {
                        // Date invalide, on ignore
                    }
                }
            } else {
                // Si ce n'est plus un entretien, on efface la date
                $candidature->setInterviewDate(null);
            }

            $entityManager->flush();
        }

        return $this->redirectToRoute('app_home');
    }
}